"""
force_full_scan.py — Lance un scan complet immédiat.
À exécuter une fois pour peupler DefectDojo avec les vulnérabilités existantes.
"""
import asyncio
from datetime import datetime, timedelta, timezone
from ocs_cache import ocs_cache
from collectors import NVDDeltaCollector, CISAKEVCollector, VendorRSSCollector
from matching import MatchingEngine
from alerting import AlertManager


async def full_scan():
    # 1. Refresh OCS
    await ocs_cache.refresh()
    print(f"✅ {len(ocs_cache.assets)} machines, {len(ocs_cache.packages_index)} packages")

    all_alerts = []
    matching = MatchingEngine()
    alerter = AlertManager()

    # 2. NVD delta — 7 derniers jours au lieu de 30min
    print("⏰ NVD delta (7 derniers jours)...")
    nvd = NVDDeltaCollector()
    nvd.last_check = datetime.now(timezone.utc) - timedelta(days=7)
    all_alerts += await nvd.collect()
    print(f"   → {len(all_alerts)} CVE critiques trouvées")

    # 3. CISA KEV — premier run charge, deuxième détecte
    print("⏰ CISA KEV (chargement initial)...")
    cisa = CISAKEVCollector()
    await cisa.collect()  # Premier run = charge le catalogue
    cisa.known_cves = set()  # Reset pour forcer la détection
    print("⏰ CISA KEV (détection)...")
    kev_alerts = await cisa.collect()  # Deuxième run = tout est nouveau
    all_alerts += kev_alerts
    print(f"   → {len(kev_alerts)} CVE activement exploitées")

    # 4. Vendor RSS
    print("⏰ Vendor RSS...")
    vendor = VendorRSSCollector()
    vendor_alerts = await vendor.collect()
    all_alerts += vendor_alerts
    print(f"   → {len(vendor_alerts)} advisories")

    print(f"\n📥 Total : {len(all_alerts)} alertes collectées")

    # 5. Match contre le parc OCS
    matched = matching.match(all_alerts)
    print(f"🎯 {len(matched)} alertes matchent le parc")

    # 6. Push dans DefectDojo
    if matched:
        print("\n📤 Push dans DefectDojo...")
        await alerter.dispatch(matched)
        print("✅ Findings pushés dans DefectDojo")
        for a in matched:
            hosts = ", ".join(a.matched_hosts[:3]) if a.matched_hosts else "aucun"
            print(f"   → {a.cve_id or a.title} | {a.severity.value} | hosts: {hosts}")
    else:
        print("ℹ️  Aucun match avec le parc actuel")


asyncio.run(full_scan())
