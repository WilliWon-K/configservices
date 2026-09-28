"""
force_full_scan.py — Lance un scan complet immédiat avec TOUTES les sources.
À exécuter pour peupler DefectDojo avec les vulnérabilités existantes.

Sources :
  - NVD delta (7 derniers jours)
  - CISA KEV (catalogue complet)
  - Vendor RSS (Microsoft, Debian, Cisco, CERT-FR, CERT-EU, Ubuntu, Red Hat)
  - InterSystems (scraper page advisories)
"""
import asyncio
from datetime import datetime, timedelta, timezone
from ocs_cache import ocs_cache
from collectors import NVDDeltaCollector, CISAKEVCollector, VendorRSSCollector
from collectors.intersystems import InterSystemsCollector
from matching import MatchingEngine
from alerting import AlertManager


async def full_scan():
    print("=" * 60)
    print("  VULN ENGINE — SCAN COMPLET")
    print("=" * 60)

    # 1. Refresh OCS
    print("\n📦 Chargement du parc OCS...")
    await ocs_cache.refresh()
    print(f"   ✅ {len(ocs_cache.assets)} machines, {len(ocs_cache.packages_index)} packages")

    all_alerts = []
    matching = MatchingEngine()
    alerter = AlertManager()

    # 2. NVD delta — 7 derniers jours
    print("\n⏰ [1/5] NVD delta (7 derniers jours)...")
    nvd = NVDDeltaCollector()
    nvd.last_check = datetime.now(timezone.utc) - timedelta(days=7)
    nvd_alerts = await nvd.collect()
    all_alerts += nvd_alerts
    print(f"   → {len(nvd_alerts)} CVE critiques trouvées")

    # 3. CISA KEV — catalogue complet
    print("\n⏰ [2/5] CISA KEV (catalogue complet)...")
    cisa = CISAKEVCollector()
    await cisa.collect()  # Premier run = charge le catalogue
    cisa.known_cves = set()  # Reset pour forcer la détection
    kev_alerts = await cisa.collect()  # Deuxième run = tout est nouveau
    all_alerts += kev_alerts
    print(f"   → {len(kev_alerts)} CVE activement exploitées")

    # 4. Vendor RSS — tous les feeds
    print("\n⏰ [3/5] Vendor RSS (tous les feeds)...")
    vendor = VendorRSSCollector()
    vendor_alerts = await vendor.collect()
    all_alerts += vendor_alerts
    print(f"   → {len(vendor_alerts)} advisories")
    print("   Feeds chargés :")
    print("     • Microsoft MSRC")
    print("     • Debian DSA")
    print("     • Cisco")
    print("     • CERT-FR Avis")
    print("     • CERT-FR Alertes")
    print("     • CERT-EU")
    print("     • Ubuntu Security")
    print("     • Red Hat Critical")

    # 5. InterSystems
    print("\n⏰ [4/5] InterSystems (scraper advisories)...")
    intersystems = InterSystemsCollector()
    is_alerts = await intersystems.collect()
    # Premier run = initial load, pas d'alertes
    if not is_alerts and intersystems.seen_urls:
        # Force un deuxième run pour tout remonter
        intersystems.seen_urls.pop()
        is_alerts = await intersystems.collect()
    all_alerts += is_alerts
    print(f"   → {len(is_alerts)} advisories InterSystems")

    # 6. Résumé
    print("\n" + "=" * 60)
    print(f"📥 Total : {len(all_alerts)} alertes collectées")
    print("=" * 60)

    # 7. Match contre le parc OCS
    print("\n🔍 Matching contre le parc OCS...")
    matched = matching.match(all_alerts)
    print(f"🎯 {len(matched)} alertes matchent le parc")

    # 8. Push dans DefectDojo
    if matched:
        print(f"\n📤 Push de {len(matched)} finding(s) dans DefectDojo...")
        await alerter.dispatch(matched)
        print("\n✅ Findings pushés dans DefectDojo :")
        for a in matched:
            hosts = ", ".join(a.matched_hosts[:3]) if a.matched_hosts else "aucun"
            zero = " ⚡ZERO-DAY" if a.is_zero_day else ""
            exploited = " 🔴EXPLOITÉ" if a.is_actively_exploited else ""
            print(f"   → {a.cve_id or a.title}")
            print(f"     Sévérité: {a.severity.value} | Hosts: {hosts}{zero}{exploited}")
    else:
        print("\nℹ️  Aucun match avec le parc actuel — le parc est clean !")

    print("\n" + "=" * 60)
    print("  SCAN TERMINÉ")
    print("=" * 60)


asyncio.run(full_scan())
