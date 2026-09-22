"""
Matching Engine — croise les nouvelles vulnérabilités avec le parc OCS.
C'est LE cœur du système : nouvelle CVE → qui est impacté ?
"""
import logging
from models import VulnAlert
from ocs_cache import ocs_cache

logger = logging.getLogger("vuln-engine.matching")


class MatchingEngine:
    """
    Prend une liste de VulnAlert (sorties des collectors) et enrichit
    chaque alerte avec les machines OCS impactées.
    """

    def match(self, alerts: list[VulnAlert]) -> list[VulnAlert]:
        """
        Pour chaque alerte, cherche dans le cache OCS les machines
        qui ont un package correspondant aux CPE affectés.
        Retourne uniquement les alertes qui matchent au moins une machine.
        """
        matched_alerts = []

        for alert in alerts:
            all_hosts = set()
            all_packages = set()

            # ── Match par CPE (NVD fournit les CPE) ──
            for cpe in alert.affected_cpe:
                hosts, pkg_name = ocs_cache.find_hosts_by_cpe(cpe)
                if hosts:
                    all_hosts.update(hosts)
                    all_packages.add(pkg_name)

            # ── Match par nom de CVE dans le titre (vendor RSS) ──
            # Les vendor advisories mentionnent souvent le produit dans le titre
            if not all_hosts and alert.source.value == "vendor_advisory":
                # Extraction heuristique du nom de produit depuis le titre
                for product_guess in self._extract_product_hints(alert.title):
                    hosts = ocs_cache.find_hosts_by_package(product_guess)
                    if hosts:
                        all_hosts.update(hosts)
                        all_packages.add(product_guess)

            if all_hosts:
                alert.matched_hosts = list(all_hosts)
                alert.matched_packages = list(all_packages)
                matched_alerts.append(alert)
                logger.warning(
                    f"MATCH: {alert.cve_id or alert.title} → "
                    f"{len(all_hosts)} host(s): {', '.join(list(all_hosts)[:5])}"
                )
            else:
                # Zero-day / CISA KEV sans match → on remonte quand même pour visibilité
                if alert.is_zero_day or alert.is_actively_exploited:
                    matched_alerts.append(alert)
                    logger.info(
                        f"ZERO-DAY (no host match): {alert.cve_id or alert.title} "
                        f"— remontée pour visibilité"
                    )

        logger.info(
            f"Matching: {len(matched_alerts)}/{len(alerts)} alerts matched or flagged"
        )
        return matched_alerts

    def _extract_product_hints(self, title: str) -> list[str]:
        """
        Heuristique : extrait des noms de produits possibles depuis un titre d'advisory.
        Ex: "[MICROSOFT_MSRC] Windows Kernel Elevation of Privilege" → ["windows", "kernel"]
        """
        # Supprime le préfixe [VENDOR]
        clean = title.split("]", 1)[-1].strip().lower()
        # Mots courants à ignorer
        stopwords = {
            "vulnerability", "advisory", "security", "update", "patch",
            "remote", "code", "execution", "elevation", "privilege",
            "denial", "service", "buffer", "overflow", "injection",
            "of", "in", "for", "the", "a", "an",
        }
        words = clean.replace("-", " ").split()
        return [w for w in words if w not in stopwords and len(w) > 2]
