"""
Point d'entrée — montre comment intégrer le vuln-engine dans ta FastAPI existante.
Tu peux soit :
  1. Copier ce fichier comme app standalone
  2. Importer router + scheduler dans ton app existante
"""
from contextlib import asynccontextmanager
from fastapi import FastAPI
from routes import router as vuln_router
from scheduler import setup_scheduler, shutdown_scheduler
import logging

# Logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(name)s] %(levelname)s: %(message)s",
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    setup_scheduler()
    yield
    # Shutdown
    shutdown_scheduler()


app = FastAPI(
    title="Vuln Engine — CS Data",
    description="Moteur de détection et d'alerting vulnérabilités / zero-day",
    version="1.0.0",
    lifespan=lifespan,
)

# ── Monte le router vuln-engine ──
app.include_router(vuln_router)


# ── Si tu intègres dans ton app existante, fais juste : ──
#
#   from vuln_engine.routes import router as vuln_router
#   from vuln_engine.scheduler import setup_scheduler, shutdown_scheduler
#
#   app.include_router(vuln_router)
#
#   @app.on_event("startup")
#   async def startup():
#       setup_scheduler()
#
#   @app.on_event("shutdown")
#   async def shutdown():
#       shutdown_scheduler()


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
