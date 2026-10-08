#!/usr/bin/env bash
set -u

REPORT="rapport-professeur.md"
NAMESPACE="cinema-exam"
SETUP_LOG=".professeur-setup.log"
PASS=0
FAIL=0
COMPOSE_STARTED=0
INGRESS_PID=""
INGRESS_OWNED=0
DETAILS_FILE="$(mktemp)"
TEST_NUMBER=0

cleanup() {
  if [ "$INGRESS_OWNED" -eq 1 ] && [ -n "$INGRESS_PID" ]; then
    kill "$INGRESS_PID" 2>/dev/null || true
  fi
  if [ "$COMPOSE_STARTED" -eq 1 ]; then
    docker compose down >/dev/null 2>&1 || true
  fi
  rm -f "$DETAILS_FILE"
}
trap cleanup EXIT

cat > "$REPORT" <<'EOF'
# Rapport de validation — CinéK8s

## 1. Informations générales

| Élément | Valeur |
|---|---|
| Date d'exécution | DATE_PLACEHOLDER |
| Périmètre | Parties 1 à 5, bonus B1 et bonus B2 |
| Projet | CinéK8s |
EOF
sed -i '' "s/DATE_PLACEHOLDER/$(date)/" "$REPORT"
if [ -f "$SETUP_LOG" ]; then
  {
    printf '\n## 2. Préparation automatique de l’environnement\n\n'
    printf 'Le lanceur a préparé automatiquement Docker, Minikube, les images, les manifests et l’Ingress avant les tests.\n\n'
    printf '<details>\n<summary>Afficher les commandes de préparation</summary>\n\n```text\n'
    sed 's/```/` ` `/g' "$SETUP_LOG"
    printf '```\n\n</details>\n'
  } >> "$REPORT"
fi
cat >> "$REPORT" <<'EOF'

## 3. Résumé exécutif

Le tableau ci-dessous permet au professeur de vérifier rapidement si les
commandes prévues ont été exécutées correctement. Les sorties techniques
complètes sont disponibles plus bas dans les sections repliables.

| Résultat | Nombre |
|---|---:|
| Tests réussis | EN_COURS |
| Tests échoués | EN_COURS |
| Total | EN_COURS |

## 4. Résultats détaillés

| N° | Partie | Vérification | Commande exécutée | Statut | Durée |
|---:|---|---|---|---|---:|
EOF

check() {
  local part="$1"
  local name="$2"
  shift 2
  local command_text="$*"
  local output_file
  local start
  local duration
  local status
  local escaped_command

  TEST_NUMBER=$((TEST_NUMBER + 1))
  output_file="$(mktemp)"
  start=$(date +%s)
  printf '[%02d] %s — %s\n' "$TEST_NUMBER" "$part" "$name" >&2
  if "$@" >"$output_file" 2>&1; then
    status="OK"
    PASS=$((PASS + 1))
  else
    status="ÉCHEC"
    FAIL=$((FAIL + 1))
  fi
  duration=$(( $(date +%s) - start ))
  escaped_command="${command_text//|/\\|}"

  printf '| %d | %s | %s | `%s` | **%s** | %ss |\n' \
    "$TEST_NUMBER" "$part" "$name" "$escaped_command" "$status" "$duration" >> "$REPORT"

  {
    printf '\n<details>\n<summary>%d — %s — %s</summary>\n\n' \
      "$TEST_NUMBER" "$part" "$name"
    printf '**Commande :** `%s`\n\n' "$command_text"
    if [ "$status" = "OK" ]; then
      printf '**Résultat :** ✅ Test réussi\n\n'
    else
      printf '**Résultat :** ❌ Test échoué\n\n'
      if grep -qi "port is already allocated" "$output_file"; then
        printf '**Diagnostic probable :** le port demandé est déjà utilisé par un autre processus ou conteneur. Libérer ce port puis relancer le script.\n\n'
      fi
    fi
    if [ -s "$output_file" ]; then
      printf '```text\n'
      sed 's/```/` ` `/g' "$output_file"
      printf '```\n'
    else
      printf '_Aucune sortie._\n'
    fi
    printf '\n</details>\n'
  } >> "$DETAILS_FILE"
  rm -f "$output_file"
  [ "$status" = "OK" ]
}

check "Partie 1" "Tests movie-service" \
  bash -c 'cd movie-service && bash mvnw -q test'
check "Partie 1" "Tests ticket-service" \
  bash -c 'cd ticket-service && bash mvnw -q test'
check "Partie 1" "Readiness incluant movie" \
  grep -q 'include: readinessState,movie' \
  ticket-service/src/main/resources/application.yaml

check "Partie 3" "Configuration Docker Compose" docker compose config
check "Partie 3" "Images Docker disponibles" \
  docker image inspect movie-service:1.0.0 ticket-service:1.0.0
check "Partie 3" "Image movie en non-root" \
  bash -c 'test "$(docker run --rm --entrypoint id movie-service:1.0.0 | sed -n "s/.*uid=\([0-9]*\).*/\1/p")" = "10001"'
check "Partie 3" "Image ticket en non-root" \
  bash -c 'test "$(docker run --rm --entrypoint id ticket-service:1.0.0 | sed -n "s/.*uid=\([0-9]*\).*/\1/p")" = "10001"'

COMPOSE_MOVIE_PORT=18080
COMPOSE_TICKET_PORT=18082
COMPOSE_STARTED=1
if check "Partie 3" "Démarrage Docker Compose" \
  env MOVIE_PORT="$COMPOSE_MOVIE_PORT" TICKET_PORT="$COMPOSE_TICKET_PORT" \
  docker compose up -d --build; then
  check "Partie 3" "Attente des services Compose" \
    bash -c 'for attempt in $(seq 1 30); do if curl -fsS "http://localhost:${MOVIE_PORT:-18080}/actuator/health/liveness" >/dev/null && curl -fsS "http://localhost:${TICKET_PORT:-18082}/actuator/health/liveness" >/dev/null; then exit 0; fi; sleep 2; done; exit 1'
  check "Partie 3" "Environnement Compose" \
    bash -c 'test "$(curl -sS "http://localhost:${MOVIE_PORT:-18080}/api/movies/whoami" | jq -r ".environment")" = "compose"'
  check "Partie 3" "Réservation Compose" \
    bash -c 'curl -sS -X POST "http://localhost:${TICKET_PORT:-18082}/api/tickets" -H "Content-Type: application/json" -d "{\"movieId\":1,\"seats\":2}" | jq -e ".total == 21.00" >/dev/null'
fi

check "Partie 4" "Namespace cinema-exam" kubectl get namespace "$NAMESPACE"
check "Partie 4" "Validation des manifests Kubernetes" \
  kubectl apply --dry-run=client -f k8s/
check "Partie 4" "Deployment movie disponible" \
  kubectl wait --for=condition=available deployment/movie -n "$NAMESPACE" --timeout=10s
check "Partie 4" "Deployment ticket disponible" \
  kubectl wait --for=condition=available deployment/ticket -n "$NAMESPACE" --timeout=10s
check "Partie 4" "Endpoints movie disponibles" \
  bash -c 'test -n "$(kubectl get endpoints movie -n cinema-exam -o jsonpath="{.subsets[*].addresses[*].ip}")"'
check "Partie 4" "Endpoints ticket disponibles" \
  bash -c 'test -n "$(kubectl get endpoints ticket -n cinema-exam -o jsonpath="{.subsets[*].addresses[*].ip}")"'

check "Bonus B1" "UID movie égal à 10001" \
  bash -c 'test "$(kubectl exec -n cinema-exam deploy/movie -- id -u)" = "10001"'
check "Bonus B1" "Système de fichiers racine en lecture seule" \
  bash -c '! kubectl exec -n cinema-exam deploy/movie -- touch /test-bonus'
check "Bonus B2" "Stratégie RollingUpdate" \
  bash -c 'test "$(kubectl get deployment movie -n cinema-exam -o jsonpath="{.spec.strategy.type}")" = "RollingUpdate"'
check "Bonus B2" "maxUnavailable égal à 0" \
  bash -c 'test "$(kubectl get deployment movie -n cinema-exam -o jsonpath="{.spec.strategy.rollingUpdate.maxUnavailable}")" = "0"'

if ! curl -fsS -H "Host: cinema.local" http://localhost:8088/api/movies \
  >/dev/null 2>&1; then
  kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8088:80 \
    >/tmp/cinema-ingress-test.log 2>&1 &
  INGRESS_PID=$!
  INGRESS_OWNED=1
  sleep 3
fi
check "Partie 5" "Port-forward Ingress actif" \
  bash -c '[ "$(curl -sS -o /dev/null -w "%{http_code}" -H "Host: cinema.local" http://localhost:8088/api/movies)" = "200" ]'

check "Partie 5" "Liste des films via Ingress" \
  bash -c 'test "$(curl -sS -H "Host: cinema.local" http://localhost:8088/api/movies | jq -r "length")" -ge 4'
check "Partie 5" "Réservation via Ingress" \
  bash -c 'curl -sS -H "Host: cinema.local" -X POST http://localhost:8088/api/tickets -H "Content-Type: application/json" -d "{\"movieId\":3,\"seats\":10}" | jq -e ".total == 90.00" >/dev/null'
check "Partie 5" "Actuator non exposé par Ingress" \
  bash -c '[ "$(curl -sS -o /dev/null -w "%{http_code}" -H "Host: cinema.local" http://localhost:8088/actuator/health)" = "404" ]'

TOTAL=$((PASS + FAIL))
if [ "$FAIL" -eq 0 ]; then
  FINAL="✅ SUCCÈS — toutes les vérifications sont passées"
else
  FINAL="❌ ÉCHEC — consulter les tests marqués ÉCHEC"
fi

sed -i '' \
  -e "s/Tests réussis | EN_COURS/Tests réussis | $PASS/" \
  -e "s/Tests échoués | EN_COURS/Tests échoués | $FAIL/" \
  -e "s/Total | EN_COURS/Total | $TOTAL/" \
  "$REPORT"

cat >> "$REPORT" <<EOF

## 5. Conclusion

### $FINAL

Les tests marqués **OK** ont été exécutés avec succès. Pour chaque test en
échec, la sortie de la commande est disponible dans la section correspondante
ci-dessous afin d'identifier rapidement s'il s'agit d'un problème du projet ou
d'un prérequis local (port déjà utilisé, Docker arrêté, Minikube arrêté, etc.).

## 6. Sorties techniques détaillées
EOF
cat "$DETAILS_FILE" >> "$REPORT"

printf '\nRapport généré : %s\n' "$REPORT"
printf 'Résultat : %d OK, %d échec(s).\n' "$PASS" "$FAIL"

if [ "$FAIL" -eq 0 ]; then
  exit 0
fi
exit 1
