#!/bin/bash

# Script de reset des runners GitLab Docker
# À placer dans scripts/reset-runners.sh

set -e

echo "=== Début du reset des runners GitLab ==="

# Définir ici tous les runners avec leurs images associées
declare -A runner_configs=(
    ["runner"]="image-runner:1"
    ["runner-cpp"]="image-runner-cpp:1"
    ["runner-python3"]="image-runner-python3:1"
    ["runner-net8.0"]="image-runner-net8.0:1"
)

# 1. Arrêt et suppression des conteneurs existants
echo "🛑 Arrêt des runners existants..."
for runner in "${!runner_configs[@]}"; do
    if docker ps -q -f name="$runner" | grep -q .; then
        echo "➡️  Arrêt et suppression de $runner"
        docker stop "$runner" || true
        docker rm "$runner" || true
    else
        echo "ℹ️  $runner n'est pas en cours d'exécution"
    fi
done

# 2. Petite pause
echo "⏳ Attente de 5 secondes..."
sleep 5

# 3. Suppression des volumes non utilisés
echo "🧽 Nettoyage des volumes orphelins..."
docker volume prune -f

# 4. Redémarrage des runners
echo "🚀 Redémarrage des runners..."
for runner in "${!runner_configs[@]}"; do
    image="${runner_configs[$runner]}"
    echo "➡️  Démarrage de $runner avec l'image $image"

    docker run -d \
        --name "$runner" \
        --restart always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v "gitlab-runner-config-${runner##*-}:/etc/gitlab-runner" \
        "$image"
done

# 5. Vérification après un petit délai
echo "⏳ Attente de démarrage (10s)..."
sleep 10

echo "✅ État des runners après reset :"
docker ps --filter "name=runner" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"

echo "✅ Tous les runners ont été réinitialisés avec succès"
