#!/bin/bash
# Rotation du token API DefectDojo
# À exécuter manuellement ou en cron mensuel

NEW_TOKEN=$(curl -k -s -X POST https://localhost:8444/api/v2/api-token-auth/ \
  -H "Content-Type: application/json" \
  -d '{"username":"will","password":"MDP"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")

if [ -z "$NEW_TOKEN" ]; then
    echo "❌ Échec de la rotation"
    exit 1
fi

# Met à jour le .env
sed -i "s/^DEFECTDOJO_API_KEY=.*/DEFECTDOJO_API_KEY=$NEW_TOKEN/" ~/vuln-engine/.env

# Redémarre le service
sudo systemctl restart vuln-engine

echo "✅ Token roté : ${NEW_TOKEN:0:8}..."
