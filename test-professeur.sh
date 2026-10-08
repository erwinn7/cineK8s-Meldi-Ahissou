#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

SETUP_LOG=".professeur-setup.log"
SETUP_FAILED=0
: > "$SETUP_LOG"

run_setup() {
  local description="$1"
  shift
  printf '[PREPARATION] %s\n' "$description"
  {
    printf '\n$'
    printf ' %q' "$@"
    printf '\n'
    if "$@"; then
      printf 'OK\n'
    else
      printf 'ECHEC\n'
      SETUP_FAILED=1
    fi
  } >> "$SETUP_LOG" 2>&1
}

for command in docker kubectl minikube; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'Outil manquant : %s\n' "$command" >&2
    printf 'Installez Docker Desktop, Minikube et kubectl puis relancez.\n' >&2
    exit 1
  fi
done

if ! docker compose version >/dev/null 2>&1; then
  printf 'Docker Compose v2 est indisponible.\n' >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  printf 'Docker Desktop doit être démarré avant de lancer ce script.\n' >&2
  exit 1
fi

if ! minikube status --profile minikube --format='{{.Host}}' 2>/dev/null \
  | grep -qx 'Running'; then
  run_setup "Démarrage de Minikube" \
    minikube start --profile minikube --cpus=2 --memory=4096
fi

run_setup "Activation de l'Ingress Minikube" \
  minikube addons enable ingress --profile minikube
run_setup "Construction des images Docker" \
  docker compose build
run_setup "Chargement de l'image movie dans Minikube" \
  minikube image load movie-service:1.0.0 --profile minikube
run_setup "Chargement de l'image ticket dans Minikube" \
  minikube image load ticket-service:1.0.0 --profile minikube
run_setup "Déploiement des manifests Kubernetes" \
  kubectl apply -f k8s/
run_setup "Attente du Deployment movie" \
  kubectl wait --for=condition=available deployment/movie \
  -n cinema-exam --timeout=180s
run_setup "Attente du Deployment ticket" \
  kubectl wait --for=condition=available deployment/ticket \
  -n cinema-exam --timeout=180s
run_setup "Attente du contrôleur Ingress" \
  kubectl wait --for=condition=available deployment/ingress-nginx-controller \
  -n ingress-nginx --timeout=180s

TEST_STATUS=0
bash test-professeur-tests.sh "$@" || TEST_STATUS=$?
rm -f "$SETUP_LOG"

if [ "$SETUP_FAILED" -ne 0 ] || [ "$TEST_STATUS" -ne 0 ]; then
  exit 1
fi
exit 0
