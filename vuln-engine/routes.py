"""
Nouveaux endpoints à intégrer dans ta FastAPI existante.
"""
from fastapi import APIRouter, Query
from datetime import datetime
from ocs_cache import ocs_cache
from scheduler import nvd_collector, cisa_collector, vendor_collector

router = APIRouter(prefix="/vuln-engine", tags=["Vulnerability Engine"])


@router.get("/feeds/status")
async def feeds_status():
    """État de santé de tous les collectors."""
    return {
        "nvd_delta": nvd_collector.status,
        "cisa_kev": cisa_collector.status,
        "vendor_rss": vendor_collector.status,
        "ocs_cache": {
            "last_refresh": ocs_cache.last_refresh,
            "total_assets": len(ocs_cache.assets),
            "total_packages": len(ocs_cache.packages_index),
        },
    }


@router.get("/inventory/summary")
async def inventory_summary():
    """Résumé du parc OCS en cache."""
    return {
        "total_machines": len(ocs_cache.assets),
        "total_unique_packages": len(ocs_cache.packages_index),
        "last_refresh": ocs_cache.last_refresh,
        "machines": [
            {
                "hostname": a.hostname,
                "ip": a.ip,
                "os": a.os,
                "package_count": len(a.packages),
                "client_tag": a.client_tag,
            }
            for a in ocs_cache.assets
        ],
    }


@router.get("/inventory/search")
async def search_package(
    package: str = Query(..., description="Nom du package à chercher dans le parc"),
):
    """Cherche quelles machines ont un package donné."""
    hosts = ocs_cache.find_hosts_by_package(package)
    return {
        "package": package,
        "matched_hosts": hosts,
        "count": len(hosts),
    }


@router.get("/exposure/{cve_id}")
async def check_exposure(cve_id: str):
    """
    Vérifie si une CVE donnée impacte le parc.
    Appelle le NVD pour récupérer les CPE, puis croise avec OCS.
    """
    import httpx
    from config import settings

    try:
        headers = {}
        if settings.NVD_API_KEY:
            headers["apiKey"] = settings.NVD_API_KEY

        async with httpx.AsyncClient(timeout=15) as client:
            resp = await client.get(
                f"{settings.NVD_API_URL}?cveId={cve_id}",
                headers=headers,
            )
            resp.raise_for_status()
            data = resp.json()

        vulns = data.get("vulnerabilities", [])
        if not vulns:
            return {"cve_id": cve_id, "found": False}

        cve = vulns[0].get("cve", {})
        affected_cpe = []
        for config in cve.get("configurations", []):
            for node in config.get("nodes", []):
                for match in node.get("cpeMatch", []):
                    if match.get("vulnerable"):
                        affected_cpe.append(match.get("criteria", ""))

        # Match contre le parc
        all_hosts = set()
        all_packages = set()
        for cpe in affected_cpe:
            hosts, pkg = ocs_cache.find_hosts_by_cpe(cpe)
            all_hosts.update(hosts)
            if pkg:
                all_packages.add(pkg)

        return {
            "cve_id": cve_id,
            "found": True,
            "affected_cpe_count": len(affected_cpe),
            "matched_hosts": list(all_hosts),
            "matched_packages": list(all_packages),
            "is_exposed": len(all_hosts) > 0,
        }

    except Exception as e:
        return {"cve_id": cve_id, "error": str(e)}
