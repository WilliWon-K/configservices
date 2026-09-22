"""
Configuration centrale du moteur de vulnérabilités.
Adapter les valeurs selon l'environnement.
"""
from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    # ── Base de données CVE existante ──
    DATABASE_URL: str = "postgresql+asyncpg://user:pass@localhost:5432/cve_db"

    # ── OCS Inventory ──
    OCS_API_URL: str = "https://ocs.internal/ocsapi/v1"
    OCS_API_USER: str = "admin"
    OCS_API_PASS: str = "changeme"

    # ── NVD API ──
    NVD_API_URL: str = "https://services.nvd.nist.gov/rest/json/cves/2.0"
    NVD_API_KEY: Optional[str] = None  # optionnel, augmente le rate limit

    # ── CISA KEV ──
    CISA_KEV_URL: str = "https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json"

    # ── Vendor RSS feeds ──
    VENDOR_FEEDS: dict = {
        "microsoft_msrc": "https://api.msrc.microsoft.com/update-guide/rss",
        "debian_dsa": "https://www.debian.org/security/dsa",
        "cisco": "https://tools.cisco.com/security/center/psirtrss20/CiscoSecurityAdvisory.xml",
        "vmware": "https://www.vmware.com/security/advisories.xml",
        "linux_kernel": "https://lore.kernel.org/linux-cve-announce/?q=d%3A0-7&x=A&o=-1&format=atom",
    }

    # ── DefectDojo ──
    DEFECTDOJO_URL: str = "https://defectdojo.internal/api/v2"
    DEFECTDOJO_API_KEY: str = "changeme"
    DEFECTDOJO_PRODUCT_ID: int = 1  # ID du produit "CS Data" dans DefectDojo

    # ── Alerting ──
    SMTP_HOST: str = "smtp.internal"
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_PASS: str = ""
    ALERT_RECIPIENTS: list[str] = ["secu@talan.com"]

    TEAMS_WEBHOOK_URL: Optional[str] = None

    # ── Scheduler intervals (secondes) ──
    NVD_DELTA_INTERVAL: int = 1800      # 30 min
    CISA_KEV_INTERVAL: int = 3600       # 1h
    VENDOR_RSS_INTERVAL: int = 3600     # 1h
    OCS_CACHE_INTERVAL: int = 7200      # 2h — refresh du cache parc

    class Config:
        env_file = ".env"


settings = Settings()
