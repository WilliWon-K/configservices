"""
Collector CISA KEV — Known Exploited Vulnerabilities.
Fichier JSON léger (~50ko), diff avec le dernier état pour détecter les ajouts.
"""
import httpx
import logging
from datetime import datetime, timezone
from config import settings
from models import VulnAlert, Severity, AlertSource, FeedStatus

logger = logging.getLogger("vuln-engine.cisa_kev")


class CISAKEVCollector:
    def __init__(self):
        self.known_cves: set[str] = set()  # CVE IDs déjà vus
        self.status = FeedStatus(name="cisa_kev")

    async def collect(self) -> list[VulnAlert]:
        """Fetch le catalogue KEV et retourne les NOUVEAUX ajouts."""
        alerts = []
        now = datetime.now(timezone.utc)

        try:
            async with httpx.AsyncClient(timeout=30) as client:
                resp = await client.get(settings.CISA_KEV_URL)
                resp.raise_for_status()
                data = resp.json()

            catalog = data.get("vulnerabilities", [])
            current_cves = {v["cveID"] for v in catalog}

            # Premier run → on charge tout sans alerter
            if not self.known_cves:
                self.known_cves = current_cves
                logger.info(f"CISA KEV: initial load, {len(current_cves)} CVEs catalogued")
                self.status.last_success = now
                self.status.status = "ok (initial load)"
                self.status.last_check = now
                return []

            # Diff : nouveaux CVE ajoutés au catalogue
            new_cves = current_cves - self.known_cves

            if new_cves:
                logger.warning(f"CISA KEV: {len(new_cves)} NEW actively exploited CVE(s)!")

                for vuln in catalog:
                    if vuln["cveID"] in new_cves:
                        alert = VulnAlert(
                            cve_id=vuln["cveID"],
                            title=f"[EXPLOITED] {vuln['cveID']} — {vuln.get('vendorProject', '')} {vuln.get('product', '')}",
                            description=vuln.get("shortDescription", ""),
                            severity=Severity.CRITICAL,
                            source=AlertSource.CISA_KEV,
                            source_url=f"https://nvd.nist.gov/vuln/detail/{vuln['cveID']}",
                            is_actively_exploited=True,
                            is_zero_day=True,  # dans le KEV = exploité activement
                            published_date=datetime.fromisoformat(
                                vuln.get("dateAdded", now.isoformat())
                            ) if vuln.get("dateAdded") else now,
                        )
                        alerts.append(alert)

            self.known_cves = current_cves
            self.status.last_success = now
            self.status.items_fetched = len(alerts)
            self.status.status = "ok"

        except Exception as e:
            logger.error(f"CISA KEV collection failed: {e}")
            self.status.errors += 1
            self.status.status = f"error: {e}"

        self.status.last_check = now
        return alerts
