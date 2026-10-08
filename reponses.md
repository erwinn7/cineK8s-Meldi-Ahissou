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

Lors d'un rolling update, `server.shutdown: graceful` permet de laisser
terminer les requêtes en cours avant l'arrêt du Pod.
