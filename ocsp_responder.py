import logging
import requests
from flask import Flask, request, Response
from cryptography import x509
from cryptography.x509 import ocsp
from cryptography.hazmat.primitives.serialization import load_pem_private_key, Encoding
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.backends import default_backend
import datetime

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

VAULT_URL = "https://<ip>:<port>/v1/<nom_pki_inter>/cert/" #URL API Vault pour afficher les certificats
OCSP_RESPONDER_KEY = "/etc/ocsp-server/ocsp-responder-certificate.key"
OCSP_RESPONDER_CERT = "/etc/ocsp-server/ocsp-responder-certificate.pem"
ISSUER_CERT = "/etc/ocsp-server/issuer.pem"

# Charge ta clé privée PEM (remplace par ton fichier et mot de passe si besoin)
with open(OCSP_RESPONDER_KEY, "rb") as key_file:
    private_key = load_pem_private_key(key_file.read(), password=None, backend=default_backend())

# Charge le certificat de l'OCSP responder
with open(OCSP_RESPONDER_CERT, "rb") as cert_file:
    responder_cert = x509.load_pem_x509_certificate(cert_file.read(), backend=default_backend())

# Charge le certificat de l'autorité de certification (CA)
# Tu dois avoir ce certificat pour créer les réponses OCSP
try:
    with open(ISSUER_CERT, "rb") as ca_file:
        ca_cert = x509.load_pem_x509_certificate(ca_file.read(), backend=default_backend())
except FileNotFoundError:
    logging.warning("Certificat CA non trouvé, utilisation du responder_cert comme CA")
    ca_cert = responder_cert

def interroger_vault(serial):
    url = VAULT_URL + serial
    try:
        response = requests.get(url, verify=False)  # Warning: cert verification désactivée, attention en prod
        response.raise_for_status()
    except requests.RequestException as e:
        logging.error(f"Erreur lors de l'interrogation Vault : {e}")
        return None

    try:
        vault_data_raw = response.json()
        logging.info(f"Réponse brute JSON de Vault : {vault_data_raw}")

        vault_data = vault_data_raw.get('data')
        if vault_data is None:
            logging.error("Structure JSON inattendue de Vault, 'data' manquant")
            return None
		
        logging.info(f"Données extraites de Vault : {vault_data}")
        return vault_data
    except Exception as e:
        logging.error(f"Erreur lors du parsing JSON Vault : {e}")
        return None

def verifier_certificat(serial):
    vault_data = interroger_vault(serial)
    if not vault_data:
        logging.warning(f"🔍 Certificat {serial} -> STATUS: UNKNOWN (non trouvé dans Vault)")
        return "unknown", None

    revocation_time = vault_data.get("revocation_time", 0)
    if revocation_time and revocation_time > 0:
        # Convertir le timestamp Unix en datetime
        revocation_datetime = datetime.datetime.fromtimestamp(revocation_time, tz=datetime.timezone.utc)
        logging.warning(f"❌ Certificat {serial} -> STATUS: REVOKED (révoqué le {revocation_datetime})")
        return "revoked", revocation_datetime
    else:
        logging.info(f"✅ Certificat {serial} -> STATUS: GOOD (valide)")
        return "good", None

@app.route("/ocsp", methods=["POST"])
def ocsp_responder():
    try:
        # Charge la requête OCSP depuis les bytes DER reçus
        ocsp_req = ocsp.load_der_ocsp_request(request.data)

        serial_number = ocsp_req.serial_number
        logging.info(f"📨 Requête OCSP reçue pour le certificat serial: {hex(serial_number)}")

        # Le format hex avec ':' est souvent utilisé, ici on normalise
        serial_hex = ":".join(f"{(serial_number >> i) & 0xFF:02x}" for i in reversed(range(0, serial_number.bit_length(), 8)))
        logging.info(f"🔍 Format hex normalisé: {serial_hex}")

        # Vérifier le statut du certificat
        cert_status, revocation_time = verifier_certificat(serial_hex)

        # Récupérer le certificat depuis Vault si disponible
        vault_data = interroger_vault(serial_hex)
        target_cert = None
        if vault_data and vault_data.get('certificate'):
            try:
                cert_pem = vault_data['certificate']
                target_cert = x509.load_pem_x509_certificate(cert_pem.encode(), backend=default_backend())
                logging.info("📄 Certificat chargé depuis Vault avec succès")
            except Exception as e:
                logging.error(f"❌ Erreur lors du chargement du certificat depuis Vault : {e}")

        builder = ocsp.OCSPResponseBuilder()	
		
        # CORRECTION: Construire la réponse selon le statut
        if cert_status == "good":
            logging.info("🔧 Construction réponse OCSP: GOOD")
            if target_cert is None:
                logging.error("❌ Impossible de créer une réponse GOOD sans le certificat")
                raise ValueError("Certificat requis pour statut GOOD")

            builder = builder.add_response(
                cert=target_cert,
                issuer=ca_cert,
                algorithm=hashes.SHA1(),
                cert_status=ocsp.OCSPCertStatus.GOOD,
                this_update=datetime.datetime.now(datetime.timezone.utc),
                next_update=datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=1),
                revocation_time=None,
                revocation_reason=None,
            )
        elif cert_status == "revoked":
            logging.info("🔧 Construction réponse OCSP: REVOKED")
            if target_cert is None:
                logging.error("❌ Impossible de créer une réponse REVOKED sans le certificat")
                raise ValueError("Certificat requis pour statut REVOKED")

            builder = builder.add_response(
                cert=target_cert,
                issuer=ca_cert,
                algorithm=hashes.SHA1(),
                cert_status=ocsp.OCSPCertStatus.REVOKED,
                this_update=datetime.datetime.now(datetime.timezone.utc),
                next_update=datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=1),
                revocation_time=revocation_time or datetime.datetime.now(datetime.timezone.utc),
                revocation_reason=x509.ReasonFlags.unspecified,
            )
        else:  # unknown
            logging.info("🔧 Construction réponse OCSP: UNKNOWN")
            # Pour UNKNOWN, on peut ne pas avoir le certificat
            # On utilise les infos de la requête OCSP
            builder = builder.add_response(
			    cert=target_cert,  # Peut être None pour UNKNOWN
                issuer=ca_cert,
                algorithm=hashes.SHA1(),
                cert_status=ocsp.OCSPCertStatus.UNKNOWN,
                this_update=datetime.datetime.now(datetime.timezone.utc),
                next_update=datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=1),
            )

        builder = builder.responder_id(ocsp.OCSPResponderEncoding.HASH, responder_cert)
        builder = builder.certificates([responder_cert])

        ocsp_response = builder.sign(private_key=private_key, algorithm=hashes.SHA256())

        logging.info(f"✅ Réponse OCSP générée avec succès - STATUS: {cert_status.upper()}")

        # Retourner la réponse en format DER
        response_der = ocsp_response.public_bytes(Encoding.DER)
        logging.info(f"📤 Envoi réponse OCSP ({len(response_der)} bytes)")

        return Response(response_der, content_type="application/ocsp-response")

    except Exception as e:
        logging.error(f"💥 Erreur dans le traitement OCSP : {e}")
        import traceback
        logging.error(traceback.format_exc())

        # Retourner une réponse d'erreur OCSP valide
        try:
            error_response = ocsp.OCSPResponseBuilder.build_unsuccessful(
                ocsp.OCSPResponseStatus.INTERNAL_ERROR
            )
            return Response(
                error_response.public_bytes(Encoding.DER),
                content_type="application/ocsp-response",
                status=200  # OCSP utilise toujours 200, l'erreur est dans la réponse
            )
        except:
            return Response("Internal Server Error", status=500)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8888)
