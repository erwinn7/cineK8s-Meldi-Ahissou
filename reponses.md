# Examen CinéK8s — Meldi AHISSOU

## Test automatique pour le professeur

Depuis la racine du projet, le professeur lance une seule commande :

```bash
bash test-professeur.sh
```

Le script prépare automatiquement l'environnement : il démarre Minikube si
nécessaire, active l'addon Ingress, construit les deux images Docker, les
charge dans Minikube, applique tous les manifests de `k8s/` et attend que les
Deployments et le contrôleur Ingress soient disponibles. Il lance ensuite le
fichier [`test-professeur-tests.sh`](</Users/meldi/Meldi_Save/UNIV/M2DWM/KUBERNETES/TP/cineK8s-Meldi-Ahissou/test-professeur-tests.sh>), qui exécute les vérifications des parties 1 à 5 ainsi que les bonus B1 et B2. Le professeur n'a donc pas à exécuter de commande Kubernetes supplémentaire.

Un rapport détaillé est généré automatiquement au format Markdown :

```text
rapport-professeur.md
```

Le rapport contient la date, les commandes de préparation, le résultat de
chaque test et un tableau récapitulatif des succès et des échecs. Les seuls
prérequis sont Docker Desktop démarré, ainsi que `minikube`, `kubectl`, `curl`
et `jq` installés. Le script ne supprime pas les ressources Kubernetes ; il
arrête uniquement son port-forward et ses conteneurs Compose temporaires.

## Partie 1

**Q1.1** — `MovieClient` lit la propriété Spring `movie.url`, grâce à 
`@Value("${movie.url}")`. La variable d'environnement `MOVIE_URL` est utilisé
pour la surcharger .

**Q1.2** —

- (a) Si le film demandé n'existe pas : **422 Unprocessable Entity**.
- (b) S'il reste moins de places que demandé : **409 Conflict**.
- (c) Si `movie-service` ne répond pas : **503 Service Unavailable**.

**Q1.3** — La ligne complétée est :

```yaml
include: readinessState,movie
```

`movie` correspond au nom du bean déclaré par `@Component("movie")` dans
`MovieHealthIndicator`. Cette dépendance doit être dans la readiness afin que
Kubernetes retire `ticket-service` des endpoints du Service lorsque
`movie-service` est indisponible, sans lui envoyer de nouvelles requêtes. Elle
ne doit pas être dans la liveness, car une panne de `movie-service` ne signifie
pas que `ticket-service` est mort et le redémarrer ne rétablirait pas la
communication et provoquerait des redémarrages inutiles.

**Q1.4** —

| Endpoint | Probe(s) Kubernetes qui l'utilisent | Conséquence d'un échec de la probe |
| --- | --- | --- |
| `/actuator/health/liveness` | `startupProbe` et `livenessProbe` | Kubernetes redémarre le conteneur après les seuils d'échec configurés. |
| `/actuator/health/readiness` | `readinessProbe` | Kubernetes retire le Pod des endpoints du Service, sans redémarrer le conteneur. |

Lors d'un rolling update, `server.shutdown: graceful` permet de laisser terminer les requêtes en cours avant l'arrêt du Pod.

## Partie 2

### Vérifications de la partie 2.1

Création d'une réservation :

```json
{
  "id": 1,
  "movieId": 2,
  "movieTitle": "Le Seigneur des Pods",
  "seats": 3,
  "total": 36.00,
  "createdAt": "2026-10-08T10:36:57.853517Z"
}
```

Readiness de `ticket-service` :

```json
{
  "status": "UP",
  "components": {
    "movie": {
      "status": "UP"
    },
    "readinessState": {
      "status": "UP"
    }
  }
}
```

### Questions de la partie 2.3

**Q2.1** — On lance `ticket-service` avec `SERVER_PORT=8082` afin de
surcharger temporairement le port défini dans `application.yaml`, car le port
`8080` est déjà utilisé par `movie-service`. Spring Boot utilise une
configuration externalisée : les variables d'environnement peuvent
remplacer les propriétés définies dans le fichier de configuration, sans
modifier le code ni le fichier YAML.

**Q2.2** — La liveness reste `UP` parce qu'elle vérifie que
`ticket-service` lui-même fonctionne et peut répondre. La readiness devient
`DOWN` parce qu'elle inclut l'indicateur `movie`, mais c'est le comportement
voulu : Kubernetes retire alors le Pod des endpoints du Service et ne lui
envoie plus de trafic, sans redémarrer inutilement le conteneur.

## Partie 3

### Questions de la partie 3.3

**Q3.1** — `pom.xml` est copié avant `src/` afin que Docker puisse réutiliser
la couche contenant les dépendances Maven tant que le fichier de dépendances
ne change pas. Si une seule ligne Java est modifiée, seule la copie de `src/`
et la compilation sont relancées, ce qui accélère la construction de l'image.

**Q3.2** — `-XX:MaxRAMPercentage=75` adapte automatiquement la taille maximale
du heap à la mémoire réellement disponible dans le conteneur. Contrairement à
`-Xmx512m`, cette option reste adaptée si la limite mémoire Kubernetes ou
Compose change, tout en laissant de la mémoire au système et aux autres
besoins de la JVM.

**Q3.3** — Compose attend que `movie` soit `healthy` avant de démarrer
`ticket`, mais Kubernetes n'a pas d'équivalent direct à
`depends_on: condition: service_healthy`. Si les Pods `ticket` démarrent avant
les Pods `movie`, leurs probes de readiness échouent temporairement : les
conteneurs restent démarrés, mais les Pods `ticket` ne sont pas ajoutés aux
endpoints du Service. Dès que `movie` devient disponible, la readiness passe à
`UP` et le trafic peut être envoyé vers `ticket`.

## Partie 4

### Vérifications de la partie 4.4

Pods déployés dans le namespace `cinema-exam` :

```text
NAME                          READY   STATUS    RESTARTS   AGE
movie-59684459f4-85n97        1/1     Running   0          6m
movie-59684459f4-95g2b        1/1     Running   0          6m
ticket-66d95c98b6-gm7qv       1/1     Running   0          6m
ticket-66d95c98b6-qq445       1/1     Running   0          6m
```

Endpoints des Services :

```text
NAME     ENDPOINTS
movie    10.244.0.85:8080,10.244.0.86:8080
ticket   10.244.0.84:8080,10.244.0.87:8080
```

Réponse de `movie-service` appelée depuis un Pod `ticket` :

```json
{
  "hostname": "movie-59684459f4-85n97",
  "environment": "kubernetes"
}
```

Readiness de `ticket-service` :

```json
{
  "status": "UP",
  "components": {
    "movie": {
      "status": "UP"
    },
    "readinessState": {
      "status": "UP"
    }
  }
}
```

Réservation créée via le port-forward du Service `ticket` :

```json
{
  "id": 1,
  "movieId": 2,
  "movieTitle": "Le Seigneur des Pods",
  "seats": 2,
  "total": 24.00,
  "createdAt": "2026-10-08T11:20:00.651618112Z"
}
```

### Questions de la partie 4.5

**Q4.1** — `kubectl apply -f k8s/` traite les fichiers par ordre
alphabétique. Les préfixes `00-`, `10-`, `20-` permettent de rendre explicite
l'ordre logique : namespace, ConfigMaps, Deployments et Services.

**Q4.2** — C'est la `startupProbe` qui est responsable. Ce n'est pas une
anomalie : elle laisse le temps à Spring Boot de démarrer avant l'activation
des probes de liveness et de readiness.

**Q4.3** — Avec `imagePullPolicy: Always`, Kubernetes tenterait de télécharger
`movie-service:1.0.0` et `ticket-service:1.0.0` depuis un registre à chaque
démarrage. Comme ces images sont locales à Minikube et ne sont pas publiées
dans un registre, le démarrage échouerait ou resterait en erreur.

## Partie 5

### Vérifications de la partie 5.3

Films accessibles via l'Ingress :

```text
Pod Fiction
Le Seigneur des Pods
Docker Wars
Rollback to the Future
```

Réservation créée via l'Ingress :

```json
{
  "id": 1,
  "movieId": 3,
  "movieTitle": "Docker Wars",
  "seats": 10,
  "total": 90.00,
  "createdAt": "2026-10-08T11:25:05.732835416Z"
}
```

Hostnames observés dans la boucle :

```text
movie-59684459f4-85n97
movie-59684459f4-95g2b
movie-59684459f4-85n97
movie-59684459f4-95g2b
movie-59684459f4-95g2b
movie-59684459f4-85n97
```

Le code HTTP obtenu pour `/actuator/health` via l'Ingress est `404`.

### Questions de la partie 5.4

**Q5.1** — Deux Pods `movie` distincts ont répondu. Le Service Kubernetes
`movie` répartit la charge entre les Pods sélectionnés par le label
`app: movie`.

**Q5.2** — Avec `pathType: Exact` sur `/api/movies`, seul le chemin exact
`/api/movies` serait reconnu. `GET /api/movies/1` ne correspondrait pas à la
règle et retournerait une erreur `404`.

**Q5.3** — Le code HTTP est `404`. C'est souhaitable, car l'Ingress n'expose
que `/api/movies` et `/api/tickets` ; les endpoints Actuator ne sont pas
accessibles depuis l'extérieur par cette route.

## Partie 6

### 6.1 — Prédictions

- (a) Après 30 secondes, les Pods `ticket` resteront `Running` mais passeront
  à `0/1 Ready`, avec `RESTARTS` égal à `0`.
- (b) `kubectl get endpoints ticket` ne contiendra plus d'adresses IP.
- (c) `GET /api/tickets` via l'Ingress retournera `503 Service Unavailable`,
  car aucun Pod `ticket` ne sera prêt derrière le Service.
- (d) La liveness de `ticket` restera `UP`.

### 6.1 — Observations et explication

Après `kubectl scale deploy/movie --replicas=0` :

```text
ticket-66d95c98b6-gm7qv   0/1   Running   1
ticket-66d95c98b6-qq445   0/1   Running   1
```

```text
NAME     ENDPOINTS
ticket   <aucune adresse>
```

La liveness de `ticket` est restée `UP` et l'Ingress a retourné `503`.
La valeur `RESTARTS=1` était antérieure à la manipulation et n'a pas
augmenté pendant la panne de `movie`.

Les quatre étapes sont :

1. Les Pods `movie` sont supprimés par le scale à zéro.
2. La readiness de chaque Pod `ticket` échoue, car l'indicateur `movie` ne
   peut plus joindre le Service `movie`.
3. Kubernetes retire les Pods `ticket` des endpoints du Service `ticket`,
   tandis que leurs conteneurs restent en fonctionnement.
4. L'Ingress ne trouve plus de backend `ticket` prêt et renvoie `503`.

Les redémarrages restent inchangés, car seule la readiness échoue ; la
liveness vérifie toujours que le processus `ticket-service` fonctionne.

### 6.2 — Tableau de dépannage

| # | Statut observé | Commande de diagnostic | Cause exacte | Correction apportée |
|---|----------------|------------------------|--------------|---------------------|
| 1 | `ErrImagePull`, puis `ImagePullBackOff` | `kubectl describe pod ...` → Events | `imagePullPolicy: Always` force la recherche de l'image dans un registre, alors que l'image est locale à Minikube. | Remplacement par `imagePullPolicy: IfNotPresent`. |
| 2 | `CreateContainerConfigError` | `kubectl describe pod ...` → Events | La ConfigMap `ticket-configmap` n'existe pas. | Remplacement par `name: ticket-config`. |
| 3 | `Running` mais `0/1` | `kubectl describe pod ...` → Events | La readiness probe utilise le port `8081`, alors que l'application écoute sur `8080`. | Remplacement du port `8081` par `8080`. |

Après la troisième correction, le Deployment `ticket-debug` a été supprimé
avec `kubectl delete -f broken/ticket-debug.yaml`.

### 6.3 — Configuration sans rebuild

`MOVIE_ENVIRONMENT` a été remplacée temporairement par `production` dans
`10-config.yaml`, puis le ConfigMap a été appliqué et le Deployment `movie`
a été redémarré avec `kubectl rollout restart deploy/movie`. Après le
rolling update, `/api/movies/whoami` a retourné :

```json
{
  "environment": "production",
  "hostname": "movie-85f8d7bf99-87fl6"
}
```

La valeur `kubernetes` a ensuite été restaurée dans `10-config.yaml` et le
Deployment `movie` a été redémarré une dernière fois pour laisser le cluster
dans son état normal.

## Partie 7 — Questions de synthèse

**Q7.1** — Le Pod `ticket` demande au DNS interne de Kubernetes de résoudre
`movie`. Le nom correspond au Service Kubernetes `movie`, qui possède une
adresse IP virtuelle et sélectionne les Pods portant le label `app: movie`.
Le kube-proxy répartit ensuite la requête envoyée au Service vers un des Pods
`movie` prêts, sur le port `8080`.

**Q7.2** — Le nombre varie car les réservations sont stockées uniquement en
mémoire dans chaque instance `ticket` : chaque Pod possède sa propre liste.
Après la suppression des Pods, ces données sont perdues et les nouveaux Pods
redémarrent avec une liste vide. La solution architecturale est d'externaliser
l'état dans une base de données persistante partagée.

**Q7.3** — Le Deployment recrée automatiquement un nouveau Pod `movie` pour
maintenir les deux réplicas déclarés, avec une nouvelle adresse IP et
éventuellement un autre nom. Avec un Pod « nu », Kubernetes ne le recréerait
pas après sa suppression : le service pourrait perdre une instance et son
contenu ou son état local serait définitivement perdu.

## Bonus

### B1 — Durcissement du Deployment `movie`

Le conteneur `movie` est configuré avec `runAsNonRoot`, l'UID `10001`,
`allowPrivilegeEscalation: false`, la suppression de toutes les capabilities
Linux et `readOnlyRootFilesystem: true`. Un volume `emptyDir` est monté sur
`/tmp`, afin que Tomcat puisse y écrire malgré le système de fichiers racine
en lecture seule.

Vérification : `id` retourne `uid=10001(spring)` et une tentative d'écriture
à la racine retourne `Read-only file system`.

### B2 — Rolling update sans coupure

Le Deployment `movie` utilise `strategy: RollingUpdate` avec
`maxUnavailable: 0` et `maxSurge: 1`. La readiness empêche d'envoyer du trafic
vers un nouveau Pod avant qu'il soit prêt, tandis que `server.shutdown:
graceful` laisse terminer les requêtes en cours avant l'arrêt d'un ancien Pod.
Le rollout testé s'est terminé sans indisponibilité des deux réplicas
disponibles.

## Checklist de rendu vérifiée

- [x] Readiness de `ticket-service` incluant `movie`.
- [x] Dockerfiles multi-stage, JRE et utilisateur non-root.
- [x] `docker-compose.yaml` avec l'environnement `compose`.
- [x] Manifests `00-namespace.yaml`, `10-config.yaml`, `20-movie.yaml`,
  `30-ticket.yaml` et `40-ingress.yaml`.
- [x] `MOVIE_URL=http://movie:8080` fourni par `ticket-config`.
- [x] Trois probes Actuator configurées ; readiness de `ticket` avec
  `timeoutSeconds: 3`.
- [x] Appel inter-services vérifié avec `kubectl exec ... wget`.
- [x] Ingress `cinema.local` routant `/api/movies` et `/api/tickets`.
- [ ] Scénario `movie` à 0 réplica : `0/1 Ready` et `503` observés ; les Pods
  `ticket` avaient déjà `RESTARTS=1` avant le test, sans redémarrage
  supplémentaire pendant la panne.
- [x] Trois bugs de `ticket-debug` documentés et corrigés.
- [x] Réponses Q1.1 à Q7.3 et sorties de commandes demandées présentes.
