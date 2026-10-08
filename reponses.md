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
