"""
Modèles de données pour le moteur de vulnérabilités.
"""
from pydantic import BaseModel
from datetime import datetime
from enum import Enum
from typing import Optional


class Severity(str, Enum):
    CRITICAL = "Critical"
    HIGH = "High"
    MEDIUM = "Medium"
    LOW = "Low"
    INFO = "Info"


class AlertSource(str, Enum):
    NVD = "nvd"
    CISA_KEV = "cisa_kev"
    VENDOR = "vendor_advisory"


class VulnAlert(BaseModel):
    """Une vulnérabilité détectée qui matche avec le parc."""
    cve_id: Optional[str] = None
    title: str
    description: str
    severity: Severity
    cvss_score: Optional[float] = None
    source: AlertSource
    source_url: Optional[str] = None
    affected_cpe: list[str] = []
    matched_hosts: list[str] = []        # hostnames OCS qui matchent
    matched_packages: list[str] = []     # packages concernés
    is_zero_day: bool = False
    is_actively_exploited: bool = False
    published_date: Optional[datetime] = None
    detected_at: datetime = datetime.now()


class OCSAsset(BaseModel):
    """Machine du parc OCS avec ses packages."""
    hostname: str
    ip: str
    os: str
    packages: list[dict]  # [{"name": "openssl", "version": "3.0.2"}, ...]
    client_tag: Optional[str] = None
    criticality: Optional[str] = None  # prod / preprod / dev


class FeedStatus(BaseModel):
    """État d'un collector."""
    name: str
    last_check: Optional[datetime] = None
    last_success: Optional[datetime] = None
    items_fetched: int = 0
    errors: int = 0
    status: str = "idle"
