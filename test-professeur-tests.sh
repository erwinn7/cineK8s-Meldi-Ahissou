#!/usr/bin/env bash
set -u

REPORT="rapport-professeur.md"
NAMESPACE="cinema-exam"
PASS=0
FAIL=0
COMPOSE_STARTED=0
INGRESS_PID=""
RESULTS_FILE="$(mktemp)"

exec > >(tee "$REPORT") 2>&1

cleanup() {
  if [ -n "$INGRESS_PID" ]; then
    kill "$INGRESS_PID" 2>/dev/null || true
  fi
  if [ "$COMPOSE_STARTED" -eq 1 ]; then
    docker compose down
  fi
  rm -f "$RESULTS_FILE"
}
trap cleanup EXIT

check() {
  local name="$1"
  shift
  printf '\n### %s\n' "$name"
  if "$@"; then
    printf -- '- **OK**\n'
    printf '  - Commande exécutée avec succès.\n'
    printf 'OK\n' >> "$RESULTS_FILE"
    PASS=$((PASS + 1))
  else
    printf -- '- **ÉCHEC**\n'
    printf '  - La vérification a échoué.\n'
    printf 'FAIL\n' >> "$RESULTS_FILE"
    FAIL=$((FAIL + 1))
  fi
}

printf '# Rapport automatique CinéK8s\n\n'
printf '**Date :** %s\n\n' "$(date)"
printf 'Les tests couvrent les parties 1 à 5 ainsi que les bonus B1 et B2.\n'
printf 'Chaque vérification est exécutée dans l’ordre et son résultat est listé ci-dessous.\n'

check "Q1 — tests movie-service" \
  bash -c 'cd movie-service && bash mvnw -q test'
check "Q1 — tests ticket-service" \
  bash -c 'cd ticket-service && bash mvnw -q test'
check "Q1 — readiness movie" \
  grep -q 'include: readinessState,movie' \
  ticket-service/src/main/resources/application.yaml

check "Q3 — configuration Compose" docker compose config
check "Q3 — images Docker" \
  docker image inspect movie-service:1.0.0 ticket-service:1.0.0
check "Q3 — image movie non-root" \
  bash -c 'test "$(docker run --rm --entrypoint id movie-service:1.0.0 | sed -n "s/.*uid=\([0-9]*\).*/\1/p")" = "10001"'
check "Q3 — image ticket non-root" \
  bash -c 'test "$(docker run --rm --entrypoint id ticket-service:1.0.0 | sed -n "s/.*uid=\([0-9]*\).*/\1/p")" = "10001"'

COMPOSE_STARTED=1
if docker compose up -d --build; then
  check "Q3 — environnement Compose" \
    bash -c 'test "$(curl -sS http://localhost:8080/api/movies/whoami | jq -r ".environment")" = "compose"'
  check "Q3 — réservation Compose" \
    bash -c 'test "$(curl -sS -X POST http://localhost:8082/api/tickets -H "Content-Type: application/json" -d "{\"movieId\":1,\"seats\":2}" | jq -r ".total")" = "21.00"'
else
  printf '\n### Q3 — démarrage Compose\n'
  printf -- '- **ÉCHEC**\n'
  printf '  - Impossible de démarrer Docker Compose.\n'
  FAIL=$((FAIL + 1))
fi

check "Q4 — namespace cinema-exam" kubectl get namespace "$NAMESPACE"
check "Q4 — manifests Kubernetes" kubectl apply --dry-run=client -f k8s/
check "Q4 — Deployment movie disponible" \
  kubectl wait --for=condition=available deployment/movie -n "$NAMESPACE" --timeout=10s
check "Q4 — Deployment ticket disponible" \
  kubectl wait --for=condition=available deployment/ticket -n "$NAMESPACE" --timeout=10s
check "Q4 — endpoints movie" \
  bash -c 'test -n "$(kubectl get endpoints movie -n cinema-exam -o jsonpath="{.subsets[*].addresses[*].ip}")"'
check "Q4 — endpoints ticket" \
  bash -c 'test -n "$(kubectl get endpoints ticket -n cinema-exam -o jsonpath="{.subsets[*].addresses[*].ip}")"'
check "Bonus B1 — movie UID 10001" \
  bash -c 'test "$(kubectl exec -n cinema-exam deploy/movie -- id -u)" = "10001"'
check "Bonus B1 — movie filesystem root en lecture seule" \
  bash -c '! kubectl exec -n cinema-exam deploy/movie -- touch /test-bonus'
check "Bonus B2 — stratégie RollingUpdate" \
  bash -c 'test "$(kubectl get deployment movie -n cinema-exam -o jsonpath="{.spec.strategy.type}")" = "RollingUpdate"'
check "Bonus B2 — aucun Pod indisponible" \
  bash -c 'test "$(kubectl get deployment movie -n cinema-exam -o jsonpath="{.spec.strategy.rollingUpdate.maxUnavailable}")" = "0"'

kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8088:80 \
  >/tmp/cinema-ingress-test.log 2>&1 &
INGRESS_PID=$!
sleep 3

check "Q5 — liste des films via Ingress" \
  bash -c 'test "$(curl -sS -H "Host: cinema.local" http://localhost:8088/api/movies | jq -r "length")" -ge 4'
check "Q5 — réservation via Ingress" \
  bash -c 'curl -sS -H "Host: cinema.local" -X POST http://localhost:8088/api/tickets -H "Content-Type: application/json" -d "{\"movieId\":3,\"seats\":10}" | jq -e ".total == 90.00" >/dev/null'
check "Q5 — Actuator non exposé" \
  bash -c '[ "$(curl -sS -o /dev/null -w "%{http_code}" -H "Host: cinema.local" http://localhost:8088/actuator/health)" = "404" ]'

printf '\n## Résumé\n\n'
printf '| Résultat | Nombre |\n'
printf '|---|---:|\n'
printf '| Tests réussis | %d |\n' "$PASS"
printf '| Tests échoués | %d |\n' "$FAIL"
if [ "$FAIL" -eq 0 ]; then
  printf '\n## Résultat final : SUCCÈS\n'
  exit 0
fi
printf '\n## Résultat final : ÉCHEC\n'
exit 1
