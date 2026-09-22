"""
Collector NVD Delta — récupère uniquement les CVE modifiées depuis le dernier check.
Ultra léger : quelques ko par appel au lieu du full dump.
"""
import httpx
import logging
from datetime import datetime, timedelta, timezone
from config import settings
from models import VulnAlert, Severity, AlertSource, FeedStatus

logger = logging.getLogger("vuln-engine.nvd_delta")


class NVDDeltaCollector:
    def __init__(self):
        self.last_check: datetime = datetime.now(timezone.utc) - timedelta(hours=1)
        self.status = FeedStatus(name="nvd_delta")

    async def collect(self) -> list[VulnAlert]:
        """Fetch les CVE modifiées depuis le dernier check."""
        alerts = []
        now = datetime.now(timezone.utc)

        params = {
            "lastModStartDate": self.last_check.strftime("%Y-%m-%dT%H:%M:%S.000"),
            "lastModEndDate": now.strftime("%Y-%m-%dT%H:%M:%S.000"),
            "cvssV3Severity": "CRITICAL",  # que les critiques pour le delta rapide
        }

        headers = {}
        if settings.NVD_API_KEY:
            headers["apiKey"] = settings.NVD_API_KEY

        try:
            async with httpx.AsyncClient(timeout=30) as client:
                resp = await client.get(
                    settings.NVD_API_URL,
                    params=params,
                    headers=headers,
                )
                resp.raise_for_status()
                data = resp.json()

            vulns = data.get("vulnerabilities", [])
            logger.info(f"NVD delta: {len(vulns)} critical CVE(s) since {self.last_check.isoformat()}")

            for item in vulns:
                cve = item.get("cve", {})
                cve_id = cve.get("id", "")
                descriptions = cve.get("descriptions", [])
                desc = next((d["value"] for d in descriptions if d["lang"] == "en"), "")

                # CVSS score
                metrics = cve.get("metrics", {})
                cvss_score = None
                for version_key in ["cvssMetricV31", "cvssMetricV30", "cvssMetricV2"]:
                    if version_key in metrics:
                        cvss_data = metrics[version_key]
                        if cvss_data:
                            cvss_score = cvss_data[0].get("cvssData", {}).get("baseScore")
                            break

                # CPE affectés
                affected_cpe = []
                configurations = cve.get("configurations", [])
                for config in configurations:
                    for node in config.get("nodes", []):
                        for match in node.get("cpeMatch", []):
                            if match.get("vulnerable"):
                                affected_cpe.append(match.get("criteria", ""))

                severity = Severity.CRITICAL if (cvss_score and cvss_score >= 9.0) else Severity.HIGH

                alert = VulnAlert(
                    cve_id=cve_id,
                    title=f"{cve_id}",
                    description=desc[:500],
                    severity=severity,
                    cvss_score=cvss_score,
                    source=AlertSource.NVD,
                    source_url=f"https://nvd.nist.gov/vuln/detail/{cve_id}",
                    affected_cpe=affected_cpe,
                    published_date=datetime.fromisoformat(
                        cve.get("published", now.isoformat()).replace("Z", "+00:00")
                    ),
                )
                alerts.append(alert)

            self.last_check = now
            self.status.last_success = now
            self.status.items_fetched = len(alerts)
            self.status.status = "ok"

        except Exception as e:
            logger.error(f"NVD delta collection failed: {e}")
            self.status.errors += 1
            self.status.status = f"error: {e}"

        self.status.last_check = now
        return alerts
