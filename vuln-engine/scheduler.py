"""
Scheduler — orchestre les collectors + matching + alerting sur des intervalles cron.
S'intègre dans le lifecycle FastAPI (startup/shutdown).
"""
import logging
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.interval import IntervalTrigger
from collectors import NVDDeltaCollector, CISAKEVCollector, VendorRSSCollector
from matching import MatchingEngine
from alerting import AlertManager
from ocs_cache import ocs_cache
from config import settings

logger = logging.getLogger("vuln-engine.scheduler")

# Instances
nvd_collector = NVDDeltaCollector()
cisa_collector = CISAKEVCollector()
vendor_collector = VendorRSSCollector()
matching_engine = MatchingEngine()
alert_manager = AlertManager()
scheduler = AsyncIOScheduler()


async def run_nvd_delta():
    """Job NVD delta — toutes les 30min."""
    logger.info("⏰ Running NVD delta collector...")
    alerts = await nvd_collector.collect()
    if alerts:
        matched = matching_engine.match(alerts)
        if matched:
            await alert_manager.dispatch(matched)


async def run_cisa_kev():
    """Job CISA KEV — toutes les heures."""
    logger.info("⏰ Running CISA KEV collector...")
    alerts = await cisa_collector.collect()
    if alerts:
        matched = matching_engine.match(alerts)
        if matched:
            await alert_manager.dispatch(matched)


async def run_vendor_rss():
    """Job Vendor RSS — toutes les heures."""
    logger.info("⏰ Running Vendor RSS collector...")
    alerts = await vendor_collector.collect()
    if alerts:
        matched = matching_engine.match(alerts)
        if matched:
            await alert_manager.dispatch(matched)


async def refresh_ocs():
    """Refresh du cache OCS — toutes les 2h."""
    await ocs_cache.refresh()


def setup_scheduler():
    """Configure et démarre le scheduler."""

    # Refresh OCS cache au démarrage
    scheduler.add_job(refresh_ocs, "date")  # run once on startup

    # Jobs récurrents
    scheduler.add_job(
        run_nvd_delta,
        IntervalTrigger(seconds=settings.NVD_DELTA_INTERVAL),
        id="nvd_delta",
        name="NVD Delta Collector",
    )
    scheduler.add_job(
        run_cisa_kev,
        IntervalTrigger(seconds=settings.CISA_KEV_INTERVAL),
        id="cisa_kev",
        name="CISA KEV Collector",
    )
    scheduler.add_job(
        run_vendor_rss,
        IntervalTrigger(seconds=settings.VENDOR_RSS_INTERVAL),
        id="vendor_rss",
        name="Vendor RSS Collector",
    )
    scheduler.add_job(
        refresh_ocs,
        IntervalTrigger(seconds=settings.OCS_CACHE_INTERVAL),
        id="ocs_refresh",
        name="OCS Cache Refresh",
    )

    scheduler.start()
    logger.info("Scheduler started with all collectors")


def shutdown_scheduler():
    scheduler.shutdown(wait=False)
