# Examen CinéK8s — NOM Prénom

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
