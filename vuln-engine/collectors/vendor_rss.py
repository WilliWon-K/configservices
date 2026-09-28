"""
Collector Vendor RSS — flux RSS/Atom des éditeurs.
Capte les advisories AVANT qu'un CVE soit publié au NVD.
"""
import feedparser
import httpx
import logging
import re
from datetime import datetime, timezone
from config import settings
from models import VulnAlert, Severity, AlertSource, FeedStatus

logger = logging.getLogger("vuln-engine.vendor_rss")


class VendorRSSCollector:
    def __init__(self):
        self.seen_ids: set[str] = set()  # entry IDs déjà traités
        self.status = FeedStatus(name="vendor_rss")

    def _extract_cve_ids(self, text: str) -> list[str]:
        """Extrait les CVE-XXXX-XXXXX depuis un texte."""
        return re.findall(r"CVE-\d{4}-\d{4,7}", text, re.IGNORECASE)

    def _guess_severity(self, text: str) -> Severity:
        """Estime la sévérité depuis le texte de l'advisory."""
        text_lower = text.lower()
        if any(w in text_lower for w in ["critical", "remote code execution", "zero-day", "actively exploited"]):
            return Severity.CRITICAL
        if any(w in text_lower for w in ["high", "important", "privilege escalation"]):
            return Severity.HIGH
        if any(w in text_lower for w in ["medium", "moderate"]):
            return Severity.MEDIUM
        return Severity.LOW

    def _is_zero_day_hint(self, text: str) -> bool:
        """Détecte les signaux zero-day dans le texte."""
        indicators = [
            "zero-day", "0-day", "actively exploited", "exploitation detected",
            "in the wild", "no patch available", "unpatched",
        ]
        text_lower = text.lower()
        return any(ind in text_lower for ind in indicators)

    async def collect(self) -> list[VulnAlert]:
        """Parse tous les feeds RSS vendors et retourne les nouvelles entrées."""
        alerts = []
        now = datetime.now(timezone.utc)
        total_new = 0

        for feed_name, feed_url in settings.VENDOR_FEEDS.items():
            try:
                # feedparser ne supporte pas async, on fetch le contenu d'abord
                async with httpx.AsyncClient(timeout=20) as client:
                    resp = await client.get(feed_url)
                    resp.raise_for_status()

                feed = feedparser.parse(resp.text)

                for entry in feed.entries:
                    entry_id = entry.get("id", entry.get("link", entry.get("title", "")))

                    # Skip si déjà vu
                    if entry_id in self.seen_ids:
                        continue

                    # Premier run → on charge sans alerter
                    if not self.seen_ids and len(feed.entries) > 5:
                        continue  # sera ajouté en bulk à la fin

                    title = entry.get("title", "No title")
                    summary = entry.get("summary", entry.get("description", ""))
                    link = entry.get("link", "")
                    full_text = f"{title} {summary}"

                    cve_ids = self._extract_cve_ids(full_text)
                    severity = self._guess_severity(full_text)
                    is_zero = self._is_zero_day_hint(full_text)

                    # On ne remonte que les HIGH+ ou zero-day
                    if severity in (Severity.CRITICAL, Severity.HIGH) or is_zero:
                        alert = VulnAlert(
                            cve_id=cve_ids[0] if cve_ids else None,
                            title=f"[{feed_name.upper()}] {title}",
                            description=summary[:500],
                            severity=Severity.CRITICAL if is_zero else severity,
                            source=AlertSource.VENDOR,
                            source_url=link,
                            is_zero_day=is_zero,
                            is_actively_exploited=is_zero,
                        )
                        alerts.append(alert)
                        total_new += 1

                # Marquer tous comme vus
                for entry in feed.entries:
                    entry_id = entry.get("id", entry.get("link", entry.get("title", "")))
                    self.seen_ids.add(entry_id)

                logger.info(f"Vendor RSS [{feed_name}]: parsed {len(feed.entries)} entries")

            except Exception as e:
                logger.error(f"Vendor RSS [{feed_name}] failed: {e}")
                self.status.errors += 1

        self.status.last_check = now
        self.status.last_success = now if total_new >= 0 else self.status.last_success
        self.status.items_fetched = total_new
        self.status.status = "ok"

        if total_new:
            logger.warning(f"Vendor RSS: {total_new} new HIGH+/zero-day advisory(ies)")

        return alerts
