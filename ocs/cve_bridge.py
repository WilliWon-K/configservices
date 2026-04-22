#!/usr/bin/env python3
"""
CVE Bridge - Fait le pont entre OCS Inventory et l'API FastAPI CVE
Lance ce script manuellement ou via cron pour alimenter les tables CVE d'OCS
"""

import asyncio
import aiohttp
import aiomysql
import logging
import re

# ─── Configuration ────────────────────────────────────────────────────────────

CVE_API_URL = "http://54.38.224.17:8000"   # URL de ton API FastAPI

OCS_DB = {
    "host": "54.38.224.17",
    "port": 3306,
    "user": "ocsuser",
    "password": "ocspass",
    "db": "ocsweb",
}

# Port MySQL exposé sur la VM hôte (à ajouter dans docker-compose, voir README)
# Si MySQL n'est pas exposé, voir section "Exposition MySQL" ci-dessous

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)
logger = logging.getLogger(__name__)

# ─── Helpers ──────────────────────────────────────────────────────────────────

def clean_version(version: str) -> str:
    """Nettoie les versions pour éviter les faux positifs"""
    if not version:
        return ""
    return version.strip()

def extract_cvss(cve: dict) -> float:
    """Extrait le score CVSS, retourne 0.0 si absent"""
    score = cve.get("cvss")
    if score is None:
        return 0.0
    try:
        return float(score)
    except (ValueError, TypeError):
        return 0.0

# ─── Logique principale ───────────────────────────────────────────────────────

async def fetch_cve_for_software(session: aiohttp.ClientSession, name: str) -> list:
    """Appelle l'API FastAPI pour un nom de logiciel"""
    try:
        url = f"{CVE_API_URL}/api/cvefor/{name}"
        async with session.get(url, timeout=aiohttp.ClientTimeout(total=3)) as resp:
            if resp.status == 200:
                data = await resp.json()
                return data if isinstance(data, list) else []
            return []
    except Exception as e:
        logger.debug(f"Aucun CVE pour '{name}': {e}")
        return []


async def get_softwares(conn) -> list:
    """Récupère tous les logiciels distincts depuis OCS (schéma normalisé)"""
    async with conn.cursor() as cur:
        await cur.execute("""
            SELECT DISTINCT
                s.HARDWARE_ID,
                h.NAME          AS hardware_name,
                sp.PUBLISHER    AS publisher,
                sn.NAME         AS software_name,
                sv.VERSION      AS version
            FROM software s
            JOIN hardware          h  ON s.HARDWARE_ID   = h.ID
            JOIN software_name     sn ON s.NAME_ID        = sn.ID
            JOIN software_publisher sp ON s.PUBLISHER_ID  = sp.ID
            JOIN software_version  sv ON s.VERSION_ID    = sv.ID
            WHERE sn.NAME IS NOT NULL AND sn.NAME != ''
            ORDER BY sn.NAME
        """)
        return await cur.fetchall()


async def clear_old_data(conn):
    """Vide les tables CVE avant de les re-remplir"""
    async with conn.cursor() as cur:
        await cur.execute("DELETE FROM cve_search_computer")
        await cur.execute("DELETE FROM cve_search")
        await conn.commit()
    logger.info("Tables CVE vidées")


async def insert_cve_computer(conn, hardware_id, hardware_name, publisher, software_name, version, cve: dict):
    """Insère une ligne dans cve_search_computer"""
    cvss = extract_cvss(cve)
    cve_id = cve.get("id", "")
    link = ""
    refs = cve.get("references", [])
    if refs:
        link = refs[0]

    async with conn.cursor() as cur:
        await cur.execute("""
            INSERT INTO cve_search_computer
                (HARDWARE_ID, HARDWARE_NAME, PUBLISHER, VERSION, SOFTWARE_NAME, CVSS, CVE, LINK)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            hardware_id,
            hardware_name or "",
            publisher or "",
            version or "",
            software_name or "",
            str(cvss),
            cve_id,
            link
        ))


async def upsert_cve_search(conn, publisher: str, name: str, version: str, cve: dict):
    """Insère dans cve_search si le CVE n'existe pas déjà pour ce logiciel"""
    cvss = extract_cvss(cve)
    cve_id = cve.get("id", "")
    link = ""
    refs = cve.get("references", [])
    if refs:
        link = refs[0]

    async with conn.cursor() as cur:
        # Récupère ou insère les IDs publisher/name/version
        # OCS utilise des colonnes PUBLISHER_ID, NAME_ID, VERSION_ID (entiers)
        # On va simplifier en stockant directement un hash numérique
        pub_id = abs(hash(publisher or "")) % 1000000
        name_id = abs(hash(name or "")) % 1000000
        ver_id = abs(hash(version or "")) % 1000000

        # Vérifie si ce CVE existe déjà
        await cur.execute(
            "SELECT ID FROM cve_search WHERE CVE = %s AND NAME_ID = %s AND VERSION_ID = %s",
            (cve_id, name_id, ver_id)
        )
        if await cur.fetchone():
            return  # Déjà présent

        await cur.execute("""
            INSERT INTO cve_search (PUBLISHER_ID, NAME_ID, VERSION_ID, CVSS, CVE, LINK)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (pub_id, name_id, ver_id, cvss, cve_id, link))


async def run():
    logger.info("=== CVE Bridge démarré ===")

    # Connexion MySQL OCS
    try:
        conn = await aiomysql.connect(**OCS_DB)
        logger.info("Connexion OCS DB OK")
    except Exception as e:
        logger.error(f"Impossible de se connecter à la DB OCS: {e}")
        logger.error("Vérifiez que le port MySQL est exposé (voir commentaires du script)")
        return

    # Récupère les logiciels
    softwares = await get_softwares(conn)
    logger.info(f"{len(softwares)} logiciels trouvés dans OCS")

    if not softwares:
        logger.warning("Aucun logiciel trouvé — vérifiez que des agents ont bien remonté leurs inventaires")
        conn.close()
        return

    # Vide les anciennes données
    await clear_old_data(conn)

    # Appels API CVE
    total_cve = 0
    async with aiohttp.ClientSession() as session:
        name_to_cves = {}
        unique_names = list({row[3] for row in softwares})
        logger.info(f"{len(unique_names)} noms de logiciels uniques à interroger")

        # Appels parallèles par batch de 50
        BATCH_SIZE = 50
        for batch_start in range(0, len(unique_names), BATCH_SIZE):
            batch = unique_names[batch_start:batch_start + BATCH_SIZE]
            tasks = [fetch_cve_for_software(session, name) for name in batch]
            results = await asyncio.gather(*tasks)
            for name, cves in zip(batch, results):
                name_to_cves[name] = cves
            done = min(batch_start + BATCH_SIZE, len(unique_names))
            found = sum(1 for c in name_to_cves.values() if c)
            logger.info(f"Progression : {done}/{len(unique_names)} — {found} logiciels avec CVE")

        # Insère les résultats
        for hardware_id, hardware_name, publisher, name, version in softwares:
            cves = name_to_cves.get(name, [])
            for cve in cves:
                await insert_cve_computer(conn, hardware_id, hardware_name, publisher, name, version, cve)
                await upsert_cve_search(conn, publisher, name, version, cve)
                total_cve += 1

        await conn.commit()

    logger.info(f"=== Terminé : {total_cve} entrées CVE insérées ===")
    conn.close()


if __name__ == "__main__":
    asyncio.run(run())
