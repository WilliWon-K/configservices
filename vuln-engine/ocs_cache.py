"""
Cache du parc OCS — pull périodique de l'inventaire pour matching rapide.
Évite de taper l'API OCS à chaque nouvelle CVE.
"""
import httpx
import logging
from datetime import datetime
from config import settings
from models import OCSAsset

logger = logging.getLogger("vuln-engine.ocs_cache")


class OCSCache:
    def __init__(self):
        self.assets: list[OCSAsset] = []
        self.packages_index: dict[str, list[str]] = {}  # package_name → [hostnames]
        self.last_refresh: datetime | None = None

    async def refresh(self):
        """Pull l'inventaire OCS et construit l'index packages→hosts."""
        logger.info("Refreshing OCS inventory cache...")
        try:
            async with httpx.AsyncClient(verify=False, timeout=60) as client:
                auth = (settings.OCS_API_USER, settings.OCS_API_PASS)
                headers = {"Accept": "application/json"}

                # 1. Liste des IDs machines
                resp = await client.get(
                    f"{settings.OCS_API_URL}/computers/listID",
                    auth=auth, headers=headers,
                )
                resp.raise_for_status()
                machine_ids = resp.json()

                new_assets = []
                new_index: dict[str, list[str]] = {}

                for entry in machine_ids:
                    machine_id = entry.get("ID", entry) if isinstance(entry, dict) else entry

                    # 2. Un seul appel — renvoie hardware + software
                    detail_resp = await client.get(
                        f"{settings.OCS_API_URL}/computer/{machine_id}/software",
                        auth=auth, headers=headers,
                    )

                    hostname, ip, os_name = "unknown", "", ""
                    packages = []

                    if detail_resp.status_code == 200:
                        data = detail_resp.json()

                        # Structure OCS : { "ID": { "hardware": {...}, "software": [...] } }
                        machine_data = data.get(str(machine_id), {})

                        # Hardware
                        hw = machine_data.get("hardware", {})
                        hostname = hw.get("NAME", "unknown")
                        ip = hw.get("IPADDR", "")
                        os_name = hw.get("OSNAME", "")

                        # Software
                        softs = machine_data.get("software", [])
                        for s in softs:
                            pkg = {
                                "name": s.get("NAME", "").lower().strip(),
                                "version": s.get("VERSION", "").strip(),
                            }
                            if pkg["name"]:
                                packages.append(pkg)
                                if pkg["name"] not in new_index:
                                    new_index[pkg["name"]] = []
                                new_index[pkg["name"]].append(hostname)

                    asset = OCSAsset(
                        hostname=hostname,
                        ip=ip,
                        os=os_name,
                        packages=packages,
                        client_tag=None,
                    )
                    new_assets.append(asset)

                self.assets = new_assets
                self.packages_index = new_index
                self.last_refresh = datetime.now()

                logger.info(
                    f"OCS cache refreshed: {len(self.assets)} machines, "
                    f"{len(self.packages_index)} unique packages"
                )

        except Exception as e:
            logger.error(f"OCS cache refresh failed: {e}")
            raise

    def find_hosts_by_package(self, package_name: str) -> list[str]:
        """Retourne les hostnames qui ont ce package installé."""
        return self.packages_index.get(package_name.lower(), [])

    def find_hosts_by_cpe(self, cpe_string: str) -> tuple[list[str], str]:
        """
        Parse un CPE (ex: cpe:2.3:a:openssl:openssl:3.0.2:*:...)
        et cherche le package correspondant dans l'index.
        Retourne (hostnames, package_name).
        """
        parts = cpe_string.split(":")
        if len(parts) >= 5:
            vendor = parts[3]
            product = parts[4]
            # Essaie product d'abord, puis vendor-product
            hosts = self.find_hosts_by_package(product)
            if not hosts:
                hosts = self.find_hosts_by_package(f"{vendor}-{product}")
            return hosts, product
        return [], ""


# Singleton
ocs_cache = OCSCache()
