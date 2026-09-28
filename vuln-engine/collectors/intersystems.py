"""
Collector InterSystems — scrape la page Product Alerts & Advisories.
Pas de flux RSS dispo, on parse le HTML directement.
"""
import httpx
import re
import logging
from datetime import datetime, timezone
from models import VulnAlert, Severity, AlertSource, FeedStatus

logger = logging.getLogger("vuln-engine.intersystems")

INTERSYSTEMS_URL = "https://www.intersystems.com/support/product-alerts-advisories/"


class InterSystemsCollector:
    def __init__(self):
        self.seen_urls: set[str] = set()
        self.status = FeedStatus(name="intersystems")

    async def collect(self) -> list[VulnAlert]:
        """Scrape les advisories InterSystems."""
        alerts = []
        now = datetime.now(timezone.utc)

        try:
            async with httpx.AsyncClient(timeout=20, follow_redirects=True) as client:
                resp = await client.get(INTERSYSTEMS_URL)
                resp.raise_for_status()

            html = resp.text

            # Étape 1 : récupère toutes les URLs d'advisories
            urls = re.findall(
                r'href=["\']'
                r'(https://www\.intersystems\.com/product-alerts-advisories/[^"\']+)'
                r'["\']',
                html,
            )
            # Dédoublonne en gardant l'ordre
            seen = set()
            unique_urls = []
            for u in urls:
                if u not in seen:
                    seen.add(u)
                    unique_urls.append(u)

            # Étape 2 : fabrique un titre lisible depuis l'URL
            entries = []
            for url in unique_urls:
                slug = url.rstrip("/").split("/")[-1]
                title = slug.replace("-", " ").title()
                entries.append((url, title))

            logger.info(f"InterSystems: found {len(entries)} advisories on page")

            # Premier run → on charge sans alerter
            if not self.seen_urls and len(entries) > 3:
                self.seen_urls = {url for url, _ in entries}
                logger.info(
                    f"InterSystems: initial load, {len(self.seen_urls)} advisories catalogued"
                )
                self.status.last_success = now
                self.status.status = "ok (initial load)"
                self.status.last_check = now
                return []

            for url, title in entries:
                if url in self.seen_urls:
                    continue

                cve_ids = re.findall(r"CVE-\d{4}-\d{4,7}", title, re.IGNORECASE)
                is_alert = "alert" in title.lower()
                is_critical = any(
                    w in title.lower()
                    for w in [
                        "critical",
                        "security",
                        "vulnerability",
                        "exploit",
                        "remote code",
                        "injection",
                        "zero-day",
                    ]
                )

                severity = (
                    Severity.CRITICAL
                    if is_critical
                    else Severity.HIGH
                    if is_alert
                    else Severity.MEDIUM
                )

                alert = VulnAlert(
                    cve_id=cve_ids[0] if cve_ids else None,
                    title=f"[INTERSYSTEMS] {title}",
                    description=title,
                    severity=severity,
                    source=AlertSource.VENDOR,
                    source_url=url,
                    is_zero_day=False,
                    is_actively_exploited=False,
                )
                alerts.append(alert)

            # Marquer tous comme vus
            for url, _ in entries:
                self.seen_urls.add(url)

            self.status.last_success = now
            self.status.items_fetched = len(alerts)
            self.status.status = "ok"

            if alerts:
                logger.warning(f"InterSystems: {len(alerts)} new advisory(ies)")

        except Exception as e:
            logger.error(f"InterSystems collection failed: {e}")
            self.status.errors += 1
            self.status.status = f"error: {e}"

        self.status.last_check = now
        return alerts
