# bulk_import_hosts.py — à lancer une fois
import httpx
import asyncio
from config import settings
from ocs_cache import ocs_cache


async def import_hosts_to_defectdojo():
    # 1. Refresh le cache OCS
    await ocs_cache.refresh()
    print(f"{len(ocs_cache.assets)} machines trouvées dans OCS")

    async with httpx.AsyncClient(verify=False, timeout=15) as client:
        headers = {
            "Authorization": f"Token {settings.DEFECTDOJO_API_KEY}",
            "Content-Type": "application/json",
        }

        for asset in ocs_cache.assets:
            payload = {
                "host": asset.hostname,
                "product": 1,  # Asset ID "CS Data" dans DefectDojo
            }

            resp = await client.post(
                f"{settings.DEFECTDOJO_URL}/endpoints/",
                json=payload,
                headers=headers,
            )

            if resp.status_code in (200, 201):
                print(f"  ✅ {asset.hostname} ({asset.os}, {len(asset.packages)} packages)")
            else:
                print(f"  ❌ {asset.hostname}: {resp.text[:100]}")

    print("Import terminé.")


asyncio.run(import_hosts_to_defectdojo())
