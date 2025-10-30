#!/bin/sh
set -e  # Stopper le script en cas d'erreur

# Vérifier si le fichier config.toml existe
if [ ! -f /etc/gitlab-runner/config.toml ]; then
  echo "Le fichier /etc/gitlab-runner/config.toml est manquant."
  echo "Lance la commande suivante pour enregistrer le runner :"
  echo "docker exec -it gitlab-runner-sonar gitlab-runner register"
  exit 1
fi

echo "GitLab Runner sont prêts ! Démarrage..."
gitlab-runner run --working-directory=/home/gitlab-runner
