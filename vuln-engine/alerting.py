"""
Module d'alerting — push les findings vers DefectDojo + envoie alertes mail/Teams.
"""
import httpx
import smtplib
import logging
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime, timezone
from config import settings
from models import VulnAlert

logger = logging.getLogger("vuln-engine.alerting")


class AlertManager:

    # ── DefectDojo ──

    async def push_to_defectdojo(self, alert: VulnAlert) -> bool:
        """Crée un finding dans DefectDojo."""
        try:
            payload = {
                "title": alert.title,
                "description": self._format_description(alert),
                "severity": alert.severity.value,
                "numerical_severity": self._severity_to_num(alert.severity),
                "active": True,
                "verified": False,
                "test": settings.DEFECTDOJO_PRODUCT_ID,
                "found_by": [1],
                "cve": alert.cve_id,
                "cvssv3_score": alert.cvss_score,
                "tags": self._build_tags(alert),
                "references": alert.source_url or "",
            }

            async with httpx.AsyncClient(timeout=15) as client:
                resp = await client.post(
                    f"{settings.DEFECTDOJO_URL}/findings/",
                    json=payload,
                    headers={
                        "Authorization": f"Token {settings.DEFECTDOJO_API_KEY}",
                        "Content-Type": "application/json",
                    },
                )

            if resp.status_code in (200, 201):
                logger.info(f"DefectDojo: finding created for {alert.cve_id or alert.title}")
                return True
            else:
                logger.error(f"DefectDojo push failed ({resp.status_code}): {resp.text[:200]}")
                return False

        except Exception as e:
            logger.error(f"DefectDojo push error: {e}")
            return False

    # ── Email ──

    async def send_email_alert(self, alert: VulnAlert):
        """Envoie une alerte par email."""
        if not settings.SMTP_HOST:
            return

        try:
            subject = f"🚨 {alert.severity.value}: {alert.cve_id or alert.title}"
            if alert.is_zero_day:
                subject = f"⚡ ZERO-DAY: {subject}"

            msg = MIMEMultipart("alternative")
            msg["Subject"] = subject
            msg["From"] = settings.SMTP_USER or "vuln-engine@talan.com"
            msg["To"] = ", ".join(settings.ALERT_RECIPIENTS)

            body = self._format_email_body(alert)
            msg.attach(MIMEText(body, "html"))

            with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT) as server:
                if settings.SMTP_USER:
                    server.starttls()
                    server.login(settings.SMTP_USER, settings.SMTP_PASS)
                server.send_message(msg)

            logger.info(f"Email alert sent for {alert.cve_id or alert.title}")

        except Exception as e:
            logger.error(f"Email alert failed: {e}")

    # ── Microsoft Teams ──

    async def send_teams_alert(self, alert: VulnAlert):
        """Envoie une alerte vers un webhook Teams."""
        if not settings.TEAMS_WEBHOOK_URL:
            return

        try:
            color = "FF0000" if alert.severity == "Critical" else "FFA500"
            emoji = "⚡" if alert.is_zero_day else "🚨"

            card = {
                "@type": "MessageCard",
                "@context": "http://schema.org/extensions",
                "themeColor": color,
                "summary": f"{emoji} {alert.title}",
                "sections": [{
                    "activityTitle": f"{emoji} {alert.severity.value} — {alert.cve_id or 'N/A'}",
                    "activitySubtitle": alert.title,
                    "facts": [
                        {"name": "Source", "value": alert.source.value},
                        {"name": "CVSS", "value": str(alert.cvss_score or "N/A")},
                        {"name": "Hosts impactés", "value": str(len(alert.matched_hosts))},
                        {"name": "Packages", "value": ", ".join(alert.matched_packages[:5]) or "N/A"},
                        {"name": "Zero-Day", "value": "✅ OUI" if alert.is_zero_day else "Non"},
                        {"name": "Exploité activement", "value": "✅ OUI" if alert.is_actively_exploited else "Non"},
                    ],
                    "markdown": True,
                }],
                "potentialAction": [{
                    "@type": "OpenUri",
                    "name": "Voir le détail",
                    "targets": [{"os": "default", "uri": alert.source_url or ""}],
                }],
            }

            async with httpx.AsyncClient(timeout=10) as client:
                resp = await client.post(settings.TEAMS_WEBHOOK_URL, json=card)
                resp.raise_for_status()

            logger.info(f"Teams alert sent for {alert.cve_id or alert.title}")

        except Exception as e:
            logger.error(f"Teams alert failed: {e}")

    # ── Dispatch ──

    async def dispatch(self, alerts: list[VulnAlert]):
        """Dispatch toutes les alertes vers tous les canaux."""
        for alert in alerts:
            await self.push_to_defectdojo(alert)

            # Email + Teams seulement pour CRITICAL ou zero-day
            if alert.severity == "Critical" or alert.is_zero_day:
                await self.send_email_alert(alert)
                await self.send_teams_alert(alert)

    # ── Helpers ──

    def _format_description(self, alert: VulnAlert) -> str:
        hosts_str = "\n".join(f"- {h}" for h in alert.matched_hosts[:20])
        return (
            f"**Source:** {alert.source.value}\n"
            f"**CVSS:** {alert.cvss_score or 'N/A'}\n"
            f"**Zero-Day:** {'Yes' if alert.is_zero_day else 'No'}\n"
            f"**Actively Exploited:** {'Yes' if alert.is_actively_exploited else 'No'}\n\n"
            f"**Description:**\n{alert.description}\n\n"
            f"**Impacted Hosts ({len(alert.matched_hosts)}):**\n{hosts_str}"
        )

    def _format_email_body(self, alert: VulnAlert) -> str:
        hosts_html = "".join(f"<li>{h}</li>" for h in alert.matched_hosts[:20])
        zero_badge = '<span style="background:red;color:white;padding:2px 8px;border-radius:4px;">ZERO-DAY</span>' if alert.is_zero_day else ""
        return f"""
        <h2>{alert.cve_id or alert.title} {zero_badge}</h2>
        <table>
            <tr><td><b>Sévérité</b></td><td>{alert.severity.value}</td></tr>
            <tr><td><b>CVSS</b></td><td>{alert.cvss_score or 'N/A'}</td></tr>
            <tr><td><b>Source</b></td><td>{alert.source.value}</td></tr>
            <tr><td><b>Exploité activement</b></td><td>{'OUI ⚠️' if alert.is_actively_exploited else 'Non'}</td></tr>
        </table>
        <h3>Description</h3>
        <p>{alert.description}</p>
        <h3>Machines impactées ({len(alert.matched_hosts)})</h3>
        <ul>{hosts_html}</ul>
        <p><a href="{alert.source_url}">Voir le détail</a></p>
        """

    def _build_tags(self, alert: VulnAlert) -> list[str]:
        tags = [alert.source.value]
        if alert.is_zero_day:
            tags.append("zero-day")
        if alert.is_actively_exploited:
            tags.append("actively-exploited")
        return tags

    def _severity_to_num(self, severity) -> str:
        mapping = {"Critical": "S0", "High": "S1", "Medium": "S2", "Low": "S3", "Info": "S4"}
        return mapping.get(severity.value, "S1")
