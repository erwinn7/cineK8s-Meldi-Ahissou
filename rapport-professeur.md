# Rapport de validation — CinéK8s

## 1. Informations générales

| Élément | Valeur |
|---|---|
| Date d'exécution | Thu Oct  8 14:31:21 CEST 2026 |
| Périmètre | Parties 1 à 5, bonus B1 et bonus B2 |
| Projet | CinéK8s |

## 2. Préparation automatique de l’environnement

Le lanceur a préparé automatiquement Docker, Minikube, les images, les manifests et l’Ingress avant les tests.

<details>
<summary>Afficher les commandes de préparation</summary>

```text

$ minikube addons enable ingress --profile minikube
* ingress is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
  - Using image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.9
  - Using image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.9
  - Using image registry.k8s.io/ingress-nginx/controller:v1.15.1
* Verifying ingress addon...
* The 'ingress' addon is enabled
OK

$ docker compose build
 Image ticket-service:1.0.0 Building 
 Image movie-service:1.0.0 Building 
#1 [internal] load local bake definitions
#1 reading from stdin 1.19kB done
#1 DONE 0.0s

#2 [movie internal] load build definition from Dockerfile
#2 transferring dockerfile: 464B done
#2 DONE 0.0s

#3 [ticket internal] load build definition from Dockerfile
#3 transferring dockerfile: 465B done
#3 DONE 0.0s

#4 [ticket internal] load metadata for docker.io/library/eclipse-temurin:21-jre-alpine
#4 DONE 0.8s

#5 [movie internal] load metadata for docker.io/library/maven:3.9-eclipse-temurin-21
#5 DONE 0.8s

#6 [ticket internal] load .dockerignore
#6 transferring context: 73B done
#6 DONE 0.0s

#7 [movie internal] load .dockerignore
#7 transferring context: 73B done
#7 DONE 0.0s

#8 [ticket stage-1 1/4] FROM docker.io/library/eclipse-temurin:21-jre-alpine@sha256:51ab5e3302e7141ce665ca3ea85e8b5cd648eafbc3c0c90dd79d6537684e4555
#8 resolve docker.io/library/eclipse-temurin:21-jre-alpine@sha256:51ab5e3302e7141ce665ca3ea85e8b5cd648eafbc3c0c90dd79d6537684e4555 0.0s done
#8 DONE 0.0s

#9 [movie build 1/6] FROM docker.io/library/maven:3.9-eclipse-temurin-21@sha256:99e61abcff91a9b1333463bd8451fb18495d6eba9250ac66a338b518f8278320
#9 resolve docker.io/library/maven:3.9-eclipse-temurin-21@sha256:99e61abcff91a9b1333463bd8451fb18495d6eba9250ac66a338b518f8278320 0.0s done
#9 DONE 0.0s

#10 [movie internal] load build context
#10 transferring context: 798B done
#10 DONE 0.0s

#11 [ticket internal] load build context
#11 transferring context: 1.02kB done
#11 DONE 0.0s

#12 [movie build 4/6] RUN mvn -q -B dependency:go-offline
#12 CACHED

#13 [movie build 5/6] COPY src ./src
#13 CACHED

#14 [movie build 6/6] RUN mvn -q -B package -DskipTests
#14 CACHED

#15 [movie build 3/6] COPY pom.xml .
#15 CACHED

#16 [ticket build 2/6] WORKDIR /app
#16 CACHED

#17 [ticket build 4/6] RUN mvn -q -B dependency:go-offline
#17 CACHED

#18 [ticket build 5/6] COPY src ./src
#18 CACHED

#19 [ticket build 3/6] COPY pom.xml .
#19 CACHED

#20 [ticket stage-1 2/4] WORKDIR /app
#20 CACHED

#21 [ticket stage-1 3/4] RUN addgroup -S spring && adduser -S -u 10001 -G spring spring
#21 CACHED

#22 [ticket build 6/6] RUN mvn -q -B package -DskipTests
#22 CACHED

#23 [movie stage-1 4/4] COPY --from=build /app/target/movie-service-1.0.0.jar app.jar
#23 CACHED

#24 [ticket stage-1 4/4] COPY --from=build /app/target/ticket-service-1.0.0.jar app.jar
#24 CACHED

#25 [ticket] exporting to image
#25 exporting layers done
#25 exporting manifest sha256:050df6701ff1d5e8022818f37b11f0eb876aeb93977fc44e81a54bc8ab95efdb done
#25 exporting config sha256:bc014d9c4ff25203196a63acecdfad2c0d75115c22453a85a2768744916d5734 done
#25 exporting attestation manifest sha256:f764fd215733c0504eaa5a95d764478b3c3266e33c43d5385548f3daf332f18c done
#25 exporting manifest list sha256:9dee6bc08de6c79cafba8f0b90db7dc3162601e6627bcf54893ec0f1075b398d done
#25 naming to docker.io/library/ticket-service:1.0.0 done
#25 unpacking to docker.io/library/ticket-service:1.0.0 done
#25 DONE 0.1s

#26 [movie] exporting to image
#26 exporting layers done
#26 exporting manifest sha256:45f38118decbc501766196f5e2e2e1346bdb1e5c4105cbfd255cd021775f4a20 done
#26 exporting config sha256:d475627b0e7a6a9bd4b4f2328fda20b0fe37d1709a56e269c594b7c12fbc41e1 done
#26 exporting attestation manifest sha256:cf3bc379b11b091d073f98f72ef77522c2a4202b17aadb9ec045507e7479e8f3 done
#26 exporting manifest list sha256:50025dc4163bc73b50d2cf4eff3adf2e78c7391814c74fde9f974840244f978d done
#26 naming to docker.io/library/movie-service:1.0.0 done
#26 unpacking to docker.io/library/movie-service:1.0.0 done
#26 DONE 0.1s

#27 [ticket] resolving provenance for metadata file
#27 DONE 0.0s

#28 [movie] resolving provenance for metadata file
#28 DONE 0.0s
 Image ticket-service:1.0.0 Built 
 Image movie-service:1.0.0 Built 
OK

$ minikube image load movie-service:1.0.0 --profile minikube
OK

$ minikube image load ticket-service:1.0.0 --profile minikube
OK

$ kubectl apply -f k8s/
namespace/cinema-exam unchanged
configmap/movie-config unchanged
configmap/ticket-config unchanged
deployment.apps/movie unchanged
service/movie unchanged
deployment.apps/ticket unchanged
service/ticket unchanged
ingress.networking.k8s.io/cinema unchanged
OK

$ kubectl wait --for=condition=available deployment/movie -n cinema-exam --timeout=180s
deployment.apps/movie condition met
OK

$ kubectl wait --for=condition=available deployment/ticket -n cinema-exam --timeout=180s
deployment.apps/ticket condition met
OK

$ kubectl wait --for=condition=available deployment/ingress-nginx-controller -n ingress-nginx --timeout=180s
deployment.apps/ingress-nginx-controller condition met
OK
```

</details>

## 3. Résumé exécutif

Le tableau ci-dessous permet au professeur de vérifier rapidement si les
commandes prévues ont été exécutées correctement. Les sorties techniques
complètes sont disponibles plus bas dans les sections repliables.

| Résultat | Nombre |
|---|---:|
| Tests réussis | 25 |
| Tests échoués | 0 |
| Total | 25 |

## 4. Résultats détaillés

| N° | Partie | Vérification | Commande exécutée | Statut | Durée |
|---:|---|---|---|---|---:|
| 1 | Partie 1 | Tests movie-service | `bash -c cd movie-service && bash mvnw -q test` | **OK** | 5s |
| 2 | Partie 1 | Tests ticket-service | `bash -c cd ticket-service && bash mvnw -q test` | **OK** | 3s |
| 3 | Partie 1 | Readiness incluant movie | `grep -q include: readinessState,movie ticket-service/src/main/resources/application.yaml` | **OK** | 0s |
| 4 | Partie 3 | Configuration Docker Compose | `docker compose config` | **OK** | 0s |
| 5 | Partie 3 | Images Docker disponibles | `docker image inspect movie-service:1.0.0 ticket-service:1.0.0` | **OK** | 0s |
| 6 | Partie 3 | Image movie en non-root | `bash -c test "$(docker run --rm --entrypoint id movie-service:1.0.0 \| sed -n "s/.*uid=\([0-9]*\).*/\1/p")" = "10001"` | **OK** | 0s |
| 7 | Partie 3 | Image ticket en non-root | `bash -c test "$(docker run --rm --entrypoint id ticket-service:1.0.0 \| sed -n "s/.*uid=\([0-9]*\).*/\1/p")" = "10001"` | **OK** | 0s |
| 8 | Partie 3 | Démarrage Docker Compose | `env MOVIE_PORT=18080 TICKET_PORT=18082 docker compose up -d --build` | **OK** | 8s |
| 9 | Partie 3 | Attente des services Compose | `bash -c for attempt in $(seq 1 30); do if curl -fsS "http://localhost:${MOVIE_PORT:-18080}/actuator/health/liveness" >/dev/null && curl -fsS "http://localhost:${TICKET_PORT:-18082}/actuator/health/liveness" >/dev/null; then exit 0; fi; sleep 2; done; exit 1` | **OK** | 4s |
| 10 | Partie 3 | Environnement Compose | `bash -c test "$(curl -sS "http://localhost:${MOVIE_PORT:-18080}/api/movies/whoami" \| jq -r ".environment")" = "compose"` | **OK** | 0s |
| 11 | Partie 3 | Réservation Compose | `bash -c curl -sS -X POST "http://localhost:${TICKET_PORT:-18082}/api/tickets" -H "Content-Type: application/json" -d "{\"movieId\":1,\"seats\":2}" \| jq -e ".total == 21.00" >/dev/null` | **OK** | 0s |
| 12 | Partie 4 | Namespace cinema-exam | `kubectl get namespace cinema-exam` | **OK** | 0s |
| 13 | Partie 4 | Validation des manifests Kubernetes | `kubectl apply --dry-run=client -f k8s/` | **OK** | 1s |
| 14 | Partie 4 | Deployment movie disponible | `kubectl wait --for=condition=available deployment/movie -n cinema-exam --timeout=10s` | **OK** | 0s |
| 15 | Partie 4 | Deployment ticket disponible | `kubectl wait --for=condition=available deployment/ticket -n cinema-exam --timeout=10s` | **OK** | 0s |
| 16 | Partie 4 | Endpoints movie disponibles | `bash -c test -n "$(kubectl get endpoints movie -n cinema-exam -o jsonpath="{.subsets[*].addresses[*].ip}")"` | **OK** | 0s |
| 17 | Partie 4 | Endpoints ticket disponibles | `bash -c test -n "$(kubectl get endpoints ticket -n cinema-exam -o jsonpath="{.subsets[*].addresses[*].ip}")"` | **OK** | 0s |
| 18 | Bonus B1 | UID movie égal à 10001 | `bash -c test "$(kubectl exec -n cinema-exam deploy/movie -- id -u)" = "10001"` | **OK** | 0s |
| 19 | Bonus B1 | Système de fichiers racine en lecture seule | `bash -c ! kubectl exec -n cinema-exam deploy/movie -- touch /test-bonus` | **OK** | 0s |
| 20 | Bonus B2 | Stratégie RollingUpdate | `bash -c test "$(kubectl get deployment movie -n cinema-exam -o jsonpath="{.spec.strategy.type}")" = "RollingUpdate"` | **OK** | 0s |
| 21 | Bonus B2 | maxUnavailable égal à 0 | `bash -c test "$(kubectl get deployment movie -n cinema-exam -o jsonpath="{.spec.strategy.rollingUpdate.maxUnavailable}")" = "0"` | **OK** | 0s |
| 22 | Partie 5 | Port-forward Ingress actif | `bash -c [ "$(curl -sS -o /dev/null -w "%{http_code}" -H "Host: cinema.local" http://localhost:8088/api/movies)" = "200" ]` | **OK** | 0s |
| 23 | Partie 5 | Liste des films via Ingress | `bash -c test "$(curl -sS -H "Host: cinema.local" http://localhost:8088/api/movies \| jq -r "length")" -ge 4` | **OK** | 0s |
| 24 | Partie 5 | Réservation via Ingress | `bash -c curl -sS -H "Host: cinema.local" -X POST http://localhost:8088/api/tickets -H "Content-Type: application/json" -d "{\"movieId\":3,\"seats\":10}" \| jq -e ".total == 90.00" >/dev/null` | **OK** | 0s |
| 25 | Partie 5 | Actuator non exposé par Ingress | `bash -c [ "$(curl -sS -o /dev/null -w "%{http_code}" -H "Host: cinema.local" http://localhost:8088/actuator/health)" = "404" ]` | **OK** | 0s |

## 5. Conclusion

### ✅ SUCCÈS — toutes les vérifications sont passées

Les tests marqués **OK** ont été exécutés avec succès. Pour chaque test en
échec, la sortie de la commande est disponible dans la section correspondante
ci-dessous afin d'identifier rapidement s'il s'agit d'un problème du projet ou
d'un prérequis local (port déjà utilisé, Docker arrêté, Minikube arrêté, etc.).

## 6. Sorties techniques détaillées

<details>
<summary>1 — Partie 1 — Tests movie-service</summary>

**Commande :** `bash -c cd movie-service && bash mvnw -q test`

**Résultat :** ✅ Test réussi

```text
WARNING: A restricted method in java.lang.System has been called
WARNING: java.lang.System::load has been called by org.fusesource.jansi.internal.JansiLoader in an unnamed module (file:/Users/meldi/.m2/wrapper/dists/apache-maven-3.9.9-bin/33b4b2b4/apache-maven-3.9.9/lib/jansi-2.4.1.jar)
WARNING: Use --enable-native-access=ALL-UNNAMED to avoid a warning for callers in this module
WARNING: Restricted methods will be blocked in a future release unless native access is enabled

WARNING: A terminally deprecated method in sun.misc.Unsafe has been called
WARNING: sun.misc.Unsafe::objectFieldOffset has been called by com.google.common.util.concurrent.AbstractFuture$UnsafeAtomicHelper (file:/Users/meldi/.m2/wrapper/dists/apache-maven-3.9.9-bin/33b4b2b4/apache-maven-3.9.9/lib/guava-33.2.1-jre.jar)
WARNING: Please consider reporting this to the maintainers of class com.google.common.util.concurrent.AbstractFuture$UnsafeAtomicHelper
WARNING: sun.misc.Unsafe::objectFieldOffset will be removed in a future release
WARNING: Final field _cipher in class org.sonatype.plexus.components.sec.dispatcher.DefaultSecDispatcher has been mutated reflectively by class org.eclipse.sisu.bean.BeanPropertyField in unnamed module @5dd6264 (file:/Users/meldi/.m2/wrapper/dists/apache-maven-3.9.9-bin/33b4b2b4/apache-maven-3.9.9/lib/org.eclipse.sisu.inject-0.9.0.M3.jar)
WARNING: Use --enable-final-field-mutation=ALL-UNNAMED to avoid a warning
WARNING: Mutating final fields will be blocked in a future release unless final field mutation is enabled
14:31:24.565 [main] INFO org.springframework.test.context.support.AnnotationConfigContextLoaderUtils -- Could not detect default configuration classes for test class [fr.k8s101.movie.MovieControllerTest]: MovieControllerTest does not declare any static, non-private, non-final, nested classes annotated with @Configuration.
14:31:24.657 [main] INFO org.springframework.boot.test.context.SpringBootTestContextBootstrapper -- Found @SpringBootConfiguration fr.k8s101.movie.MovieApplication for test class fr.k8s101.movie.MovieControllerTest

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/

 :: Spring Boot ::                (v3.5.0)

2026-10-08T14:31:24.992+02:00  INFO 21127 --- [           main] fr.k8s101.movie.MovieControllerTest      : Starting MovieControllerTest using Java 27 with PID 21127 (started by meldi in /Users/meldi/Meldi_Save/UNIV/M2DWM/KUBERNETES/TP/cineK8s-Meldi-Ahissou/movie-service)
2026-10-08T14:31:24.993+02:00  INFO 21127 --- [           main] fr.k8s101.movie.MovieControllerTest      : No active profile set, falling back to 1 default profile: "default"
2026-10-08T14:31:25.593+02:00  INFO 21127 --- [           main] o.s.b.t.m.w.SpringBootMockServletContext : Initializing Spring TestDispatcherServlet ''
2026-10-08T14:31:25.593+02:00  INFO 21127 --- [           main] o.s.t.web.servlet.TestDispatcherServlet  : Initializing Servlet ''
2026-10-08T14:31:25.594+02:00  INFO 21127 --- [           main] o.s.t.web.servlet.TestDispatcherServlet  : Completed initialization in 0 ms
2026-10-08T14:31:25.610+02:00  INFO 21127 --- [           main] fr.k8s101.movie.MovieControllerTest      : Started MovieControllerTest in 0.911 seconds (process running for 1.486)
Mockito is currently self-attaching to enable the inline-mock-maker. This will no longer work in future releases of the JDK. Please add Mockito as an agent to your build as described in Mockito's documentation: https://javadoc.io/doc/org.mockito/mockito-core/latest/org.mockito/org/mockito/Mockito.html#0.3
OpenJDK 64-Bit Server VM warning: Sharing is only supported for boot loader classes because bootstrap classpath has been appended
WARNING: A Java agent has been loaded dynamically (/Users/meldi/.m2/repository/net/bytebuddy/byte-buddy-agent/1.17.5/byte-buddy-agent-1.17.5.jar)
WARNING: If a serviceability tool is in use, please run with -XX:+EnableDynamicAgentLoading to hide this warning
WARNING: If a serviceability tool is not in use, please run with -Djdk.instrument.traceUsage for more information
WARNING: Dynamic loading of agents will be disallowed by default in a future release
```

</details>

<details>
<summary>2 — Partie 1 — Tests ticket-service</summary>

**Commande :** `bash -c cd ticket-service && bash mvnw -q test`

**Résultat :** ✅ Test réussi

```text
WARNING: A restricted method in java.lang.System has been called
WARNING: java.lang.System::load has been called by org.fusesource.jansi.internal.JansiLoader in an unnamed module (file:/Users/meldi/.m2/wrapper/dists/apache-maven-3.9.9-bin/33b4b2b4/apache-maven-3.9.9/lib/jansi-2.4.1.jar)
WARNING: Use --enable-native-access=ALL-UNNAMED to avoid a warning for callers in this module
WARNING: Restricted methods will be blocked in a future release unless native access is enabled

WARNING: A terminally deprecated method in sun.misc.Unsafe has been called
WARNING: sun.misc.Unsafe::objectFieldOffset has been called by com.google.common.util.concurrent.AbstractFuture$UnsafeAtomicHelper (file:/Users/meldi/.m2/wrapper/dists/apache-maven-3.9.9-bin/33b4b2b4/apache-maven-3.9.9/lib/guava-33.2.1-jre.jar)
WARNING: Please consider reporting this to the maintainers of class com.google.common.util.concurrent.AbstractFuture$UnsafeAtomicHelper
WARNING: sun.misc.Unsafe::objectFieldOffset will be removed in a future release
WARNING: Final field _cipher in class org.sonatype.plexus.components.sec.dispatcher.DefaultSecDispatcher has been mutated reflectively by class org.eclipse.sisu.bean.BeanPropertyField in unnamed module @5dd6264 (file:/Users/meldi/.m2/wrapper/dists/apache-maven-3.9.9-bin/33b4b2b4/apache-maven-3.9.9/lib/org.eclipse.sisu.inject-0.9.0.M3.jar)
WARNING: Use --enable-final-field-mutation=ALL-UNNAMED to avoid a warning
WARNING: Mutating final fields will be blocked in a future release unless final field mutation is enabled
14:31:28.288 [main] INFO org.springframework.test.context.support.AnnotationConfigContextLoaderUtils -- Could not detect default configuration classes for test class [fr.k8s101.ticket.TicketControllerTest]: TicketControllerTest does not declare any static, non-private, non-final, nested classes annotated with @Configuration.
14:31:28.405 [main] INFO org.springframework.boot.test.context.SpringBootTestContextBootstrapper -- Found @SpringBootConfiguration fr.k8s101.ticket.TicketApplication for test class fr.k8s101.ticket.TicketControllerTest

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/

 :: Spring Boot ::                (v3.5.0)

2026-10-08T14:31:28.688+02:00  INFO 21167 --- [           main] fr.k8s101.ticket.TicketControllerTest    : Starting TicketControllerTest using Java 27 with PID 21167 (started by meldi in /Users/meldi/Meldi_Save/UNIV/M2DWM/KUBERNETES/TP/cineK8s-Meldi-Ahissou/ticket-service)
2026-10-08T14:31:28.690+02:00  INFO 21167 --- [           main] fr.k8s101.ticket.TicketControllerTest    : No active profile set, falling back to 1 default profile: "default"
Mockito is currently self-attaching to enable the inline-mock-maker. This will no longer work in future releases of the JDK. Please add Mockito as an agent to your build as described in Mockito's documentation: https://javadoc.io/doc/org.mockito/mockito-core/latest/org.mockito/org/mockito/Mockito.html#0.3
OpenJDK 64-Bit Server VM warning: Sharing is only supported for boot loader classes because bootstrap classpath has been appended
WARNING: A Java agent has been loaded dynamically (/Users/meldi/.m2/repository/net/bytebuddy/byte-buddy-agent/1.17.5/byte-buddy-agent-1.17.5.jar)
WARNING: If a serviceability tool is in use, please run with -XX:+EnableDynamicAgentLoading to hide this warning
WARNING: If a serviceability tool is not in use, please run with -Djdk.instrument.traceUsage for more information
WARNING: Dynamic loading of agents will be disallowed by default in a future release
2026-10-08T14:31:29.703+02:00  INFO 21167 --- [           main] o.s.b.t.m.w.SpringBootMockServletContext : Initializing Spring TestDispatcherServlet ''
2026-10-08T14:31:29.704+02:00  INFO 21167 --- [           main] o.s.t.web.servlet.TestDispatcherServlet  : Initializing Servlet ''
2026-10-08T14:31:29.705+02:00  INFO 21167 --- [           main] o.s.t.web.servlet.TestDispatcherServlet  : Completed initialization in 0 ms
2026-10-08T14:31:29.741+02:00  INFO 21167 --- [           main] fr.k8s101.ticket.TicketControllerTest    : Started TicketControllerTest in 1.304 seconds (process running for 1.92)
```

</details>

<details>
<summary>3 — Partie 1 — Readiness incluant movie</summary>

**Commande :** `grep -q include: readinessState,movie ticket-service/src/main/resources/application.yaml`

**Résultat :** ✅ Test réussi

_Aucune sortie._

</details>

<details>
<summary>4 — Partie 3 — Configuration Docker Compose</summary>

**Commande :** `docker compose config`

**Résultat :** ✅ Test réussi

```text
name: cinek8s-meldi-ahissou
services:
  movie:
    build:
      context: /Users/meldi/Meldi_Save/UNIV/M2DWM/KUBERNETES/TP/cineK8s-Meldi-Ahissou/movie-service
      dockerfile: Dockerfile
    environment:
      MOVIE_ENVIRONMENT: compose
    healthcheck:
      test:
        - CMD
        - wget
        - -qO-
        - http://localhost:8080/actuator/health/liveness
      interval: 5s
      retries: 20
    image: movie-service:1.0.0
    networks:
      default: null
    ports:
      - mode: ingress
        target: 8080
        published: "8080"
        protocol: tcp
  ticket:
    build:
      context: /Users/meldi/Meldi_Save/UNIV/M2DWM/KUBERNETES/TP/cineK8s-Meldi-Ahissou/ticket-service
      dockerfile: Dockerfile
    depends_on:
      movie:
        condition: service_healthy
        required: true
    environment:
      MOVIE_URL: http://movie:8080
    image: ticket-service:1.0.0
    networks:
      default: null
    ports:
      - mode: ingress
        target: 8080
        published: "8082"
        protocol: tcp
networks:
  default:
    name: cinek8s-meldi-ahissou_default
```

</details>

<details>
<summary>5 — Partie 3 — Images Docker disponibles</summary>

**Commande :** `docker image inspect movie-service:1.0.0 ticket-service:1.0.0`

**Résultat :** ✅ Test réussi

```text
[
    {
        "Id": "sha256:50025dc4163bc73b50d2cf4eff3adf2e78c7391814c74fde9f974840244f978d",
        "RepoTags": [
            "movie-service:1.0.0"
        ],
        "RepoDigests": [
            "movie-service@sha256:50025dc4163bc73b50d2cf4eff3adf2e78c7391814c74fde9f974840244f978d"
        ],
        "Comment": "buildkit.dockerfile.v0",
        "Created": "2026-10-08T11:06:14.021090421Z",
        "Config": {
            "User": "spring",
            "ExposedPorts": {
                "8080/tcp": {}
            },
            "Env": [
                "PATH=/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "JAVA_HOME=/opt/java/openjdk",
                "LANG=en_US.UTF-8",
                "LANGUAGE=en_US:en",
                "LC_ALL=en_US.UTF-8",
                "JAVA_VERSION=jdk-21.0.12.1+1"
            ],
            "Entrypoint": [
                "java",
                "-XX:MaxRAMPercentage=75",
                "-jar",
                "app.jar"
            ],
            "WorkingDir": "/app",
            "Labels": {
                "com.docker.compose.project": "cinek8s-meldi-ahissou",
                "com.docker.compose.service": "movie",
                "com.docker.compose.version": "5.5.1"
            }
        },
        "Architecture": "arm64",
        "Os": "linux",
        "Size": 330560087,
        "RootFS": {
            "Type": "layers",
            "Layers": [
                "sha256:1b349a3334531b575b01d409540dd8aca14ef29abddacd50f36643d7c949db4b",
                "sha256:aac728fd3ce4546fcabb73b22c96d337f2e5b41446ea7756063d9914a2ba953f",
                "sha256:bbef55f547ea0a4437d7ddad811074167f07b1c2fed221ef0b0ca71cb9562c2a",
                "sha256:4878aeba7f54bd1fb75b8e6df664b990403226965e7b001b89a9021a645cd7f1",
                "sha256:70e1f02049c7e565db85f7dff1fc48e21684e28eeffb9122746487d8c41d9c7b",
                "sha256:87bce6ccce277da838e895d151b1ab52785ab8a4b749b29f7b8eee8cbf530403",
                "sha256:84a2d87dd9655ff7436d07a2da10551e7d04a6dd52fc5972f11ce1e051f920de",
                "sha256:a7fe7e6a3b26b32f128b817d3c30fe7dcf9a44acaf9818f10e401a6bcd20756b"
            ]
        },
        "Metadata": {
            "LastTagTime": "2026-10-08T12:30:56.242541635Z"
        },
        "Descriptor": {
            "mediaType": "application/vnd.oci.image.index.v1+json",
            "digest": "sha256:50025dc4163bc73b50d2cf4eff3adf2e78c7391814c74fde9f974840244f978d",
            "size": 856
        },
        "Identity": {
            "Build": [
                {
                    "Ref": "ia4fnvfenn6ysdh8kzox9pnj1",
                    "CreatedAt": "2026-10-08T12:30:56.249283718Z"
                }
            ]
        }
    },
    {
        "Id": "sha256:9dee6bc08de6c79cafba8f0b90db7dc3162601e6627bcf54893ec0f1075b398d",
        "RepoTags": [
            "ticket-service:1.0.0"
        ],
        "RepoDigests": [
            "ticket-service@sha256:9dee6bc08de6c79cafba8f0b90db7dc3162601e6627bcf54893ec0f1075b398d"
        ],
        "Comment": "buildkit.dockerfile.v0",
        "Created": "2026-10-08T11:06:12.116854003Z",
        "Config": {
            "User": "spring",
            "ExposedPorts": {
                "8080/tcp": {}
            },
            "Env": [
                "PATH=/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "JAVA_HOME=/opt/java/openjdk",
                "LANG=en_US.UTF-8",
                "LANGUAGE=en_US:en",
                "LC_ALL=en_US.UTF-8",
                "JAVA_VERSION=jdk-21.0.12.1+1"
            ],
            "Entrypoint": [
                "java",
                "-XX:MaxRAMPercentage=75",
                "-jar",
                "app.jar"
            ],
            "WorkingDir": "/app",
            "Labels": {
                "com.docker.compose.project": "cinek8s-meldi-ahissou",
                "com.docker.compose.service": "ticket",
                "com.docker.compose.version": "5.5.1"
            }
        },
        "Architecture": "arm64",
        "Os": "linux",
        "Size": 330567008,
        "RootFS": {
            "Type": "layers",
            "Layers": [
                "sha256:1b349a3334531b575b01d409540dd8aca14ef29abddacd50f36643d7c949db4b",
                "sha256:aac728fd3ce4546fcabb73b22c96d337f2e5b41446ea7756063d9914a2ba953f",
                "sha256:bbef55f547ea0a4437d7ddad811074167f07b1c2fed221ef0b0ca71cb9562c2a",
                "sha256:4878aeba7f54bd1fb75b8e6df664b990403226965e7b001b89a9021a645cd7f1",
                "sha256:70e1f02049c7e565db85f7dff1fc48e21684e28eeffb9122746487d8c41d9c7b",
                "sha256:87bce6ccce277da838e895d151b1ab52785ab8a4b749b29f7b8eee8cbf530403",
                "sha256:84a2d87dd9655ff7436d07a2da10551e7d04a6dd52fc5972f11ce1e051f920de",
                "sha256:ca703150826379ded35df8932367756adcdedbb11257a38e89d813c66863dfcd"
            ]
        },
        "Metadata": {
            "LastTagTime": "2026-10-08T12:30:56.24180926Z"
        },
        "Descriptor": {
            "mediaType": "application/vnd.oci.image.index.v1+json",
            "digest": "sha256:9dee6bc08de6c79cafba8f0b90db7dc3162601e6627bcf54893ec0f1075b398d",
            "size": 856
        },
        "Identity": {
            "Build": [
                {
                    "Ref": "lxbnuiy4rsceyoueye61vn7q4",
                    "CreatedAt": "2026-10-08T12:30:56.248806718Z"
                }
            ]
        }
    }
]
```

</details>

<details>
<summary>6 — Partie 3 — Image movie en non-root</summary>

**Commande :** `bash -c test "$(docker run --rm --entrypoint id movie-service:1.0.0 | sed -n "s/.*uid=\([0-9]*\).*/\1/p")" = "10001"`

**Résultat :** ✅ Test réussi

_Aucune sortie._

</details>

<details>
<summary>7 — Partie 3 — Image ticket en non-root</summary>

**Commande :** `bash -c test "$(docker run --rm --entrypoint id ticket-service:1.0.0 | sed -n "s/.*uid=\([0-9]*\).*/\1/p")" = "10001"`

**Résultat :** ✅ Test réussi

_Aucune sortie._

</details>

<details>
<summary>8 — Partie 3 — Démarrage Docker Compose</summary>

**Commande :** `env MOVIE_PORT=18080 TICKET_PORT=18082 docker compose up -d --build`

**Résultat :** ✅ Test réussi

```text
 Image movie-service:1.0.0 Building 
 Image ticket-service:1.0.0 Building 
#1 [internal] load local bake definitions
#1 reading from stdin 1.19kB done
#1 DONE 0.0s

#2 [movie internal] load build definition from Dockerfile
#2 transferring dockerfile: 464B done
#2 DONE 0.0s

#3 [ticket internal] load build definition from Dockerfile
#3 transferring dockerfile: 465B 0.0s done
#3 DONE 0.0s

#4 [movie internal] load metadata for docker.io/library/eclipse-temurin:21-jre-alpine
#4 DONE 0.5s

#5 [movie internal] load metadata for docker.io/library/maven:3.9-eclipse-temurin-21
#5 DONE 0.5s

#6 [movie internal] load .dockerignore
#6 transferring context: 73B done
#6 DONE 0.0s

#7 [ticket internal] load .dockerignore
#7 transferring context: 73B done
#7 DONE 0.0s

#8 [movie stage-1 1/4] FROM docker.io/library/eclipse-temurin:21-jre-alpine@sha256:51ab5e3302e7141ce665ca3ea85e8b5cd648eafbc3c0c90dd79d6537684e4555
#8 resolve docker.io/library/eclipse-temurin:21-jre-alpine@sha256:51ab5e3302e7141ce665ca3ea85e8b5cd648eafbc3c0c90dd79d6537684e4555 0.0s done
#8 DONE 0.0s

#9 [movie build 1/6] FROM docker.io/library/maven:3.9-eclipse-temurin-21@sha256:99e61abcff91a9b1333463bd8451fb18495d6eba9250ac66a338b518f8278320
#9 resolve docker.io/library/maven:3.9-eclipse-temurin-21@sha256:99e61abcff91a9b1333463bd8451fb18495d6eba9250ac66a338b518f8278320 0.0s done
#9 DONE 0.0s

#10 [movie internal] load build context
#10 transferring context: 798B done
#10 DONE 0.0s

#11 [ticket internal] load build context
#11 transferring context: 1.02kB done
#11 DONE 0.0s

#12 [movie build 4/6] RUN mvn -q -B dependency:go-offline
#12 CACHED

#13 [movie build 6/6] RUN mvn -q -B package -DskipTests
#13 CACHED

#14 [movie build 5/6] COPY src ./src
#14 CACHED

#15 [movie build 3/6] COPY pom.xml .
#15 CACHED

#16 [movie stage-1 4/4] COPY --from=build /app/target/movie-service-1.0.0.jar app.jar
#16 CACHED

#17 [movie build 2/6] WORKDIR /app
#17 CACHED

#18 [ticket build 4/6] RUN mvn -q -B dependency:go-offline
#18 CACHED

#19 [ticket build 5/6] COPY src ./src
#19 CACHED

#20 [movie stage-1 2/4] WORKDIR /app
#20 CACHED

#21 [movie stage-1 3/4] RUN addgroup -S spring && adduser -S -u 10001 -G spring spring
#21 CACHED

#22 [ticket build 3/6] COPY pom.xml .
#22 CACHED

#23 [ticket build 6/6] RUN mvn -q -B package -DskipTests
#23 CACHED

#24 [ticket stage-1 4/4] COPY --from=build /app/target/ticket-service-1.0.0.jar app.jar
#24 CACHED

#25 [ticket] exporting to image
#25 exporting layers done
#25 exporting manifest sha256:050df6701ff1d5e8022818f37b11f0eb876aeb93977fc44e81a54bc8ab95efdb done
#25 exporting config sha256:bc014d9c4ff25203196a63acecdfad2c0d75115c22453a85a2768744916d5734 done
#25 exporting attestation manifest sha256:2020a2567a1acfe6a006afde82ac323bd91a8fbe7de9f7bb41c91541e1a32ddf done
#25 exporting manifest list sha256:7678011707cabe7d5e24947f227dfcd55138abdda21793b79c549dc559486f70 done
#25 naming to docker.io/library/ticket-service:1.0.0 done
#25 unpacking to docker.io/library/ticket-service:1.0.0 done
#25 DONE 0.1s

#26 [movie] exporting to image
#26 exporting layers done
#26 exporting manifest sha256:45f38118decbc501766196f5e2e2e1346bdb1e5c4105cbfd255cd021775f4a20 done
#26 exporting config sha256:d475627b0e7a6a9bd4b4f2328fda20b0fe37d1709a56e269c594b7c12fbc41e1 done
#26 exporting attestation manifest sha256:fa06b752106d98cc01a871bbe0fd34b71d90a58c811263f5906bb8dc36102e06 done
#26 exporting manifest list sha256:a481f0bed2d41424f0122b13e9e9cbf541506dab7968a1cf9abfe853c2d8b74b done
#26 naming to docker.io/library/movie-service:1.0.0 done
#26 unpacking to docker.io/library/movie-service:1.0.0 done
#26 DONE 0.1s

#27 [movie] resolving provenance for metadata file
#27 DONE 0.0s

#28 [ticket] resolving provenance for metadata file
#28 DONE 0.0s
 Image movie-service:1.0.0 Built 
 Image ticket-service:1.0.0 Built 
 Network cinek8s-meldi-ahissou_default Creating 
 Network cinek8s-meldi-ahissou_default Creating 
 Network cinek8s-meldi-ahissou_default Created 
 Network cinek8s-meldi-ahissou_default Created 
 Container cinek8s-meldi-ahissou-movie-1 Creating 
 Container cinek8s-meldi-ahissou-movie-1 Created 
 Container cinek8s-meldi-ahissou-ticket-1 Creating 
 Container cinek8s-meldi-ahissou-ticket-1 Created 
 Container cinek8s-meldi-ahissou-movie-1 Starting 
 Container cinek8s-meldi-ahissou-movie-1 Started 
 Container cinek8s-meldi-ahissou-movie-1 Waiting 
 Container cinek8s-meldi-ahissou-movie-1 Healthy 
 Container cinek8s-meldi-ahissou-ticket-1 Starting 
 Container cinek8s-meldi-ahissou-ticket-1 Started 
```

</details>

<details>
<summary>9 — Partie 3 — Attente des services Compose</summary>

**Commande :** `bash -c for attempt in $(seq 1 30); do if curl -fsS "http://localhost:${MOVIE_PORT:-18080}/actuator/health/liveness" >/dev/null && curl -fsS "http://localhost:${TICKET_PORT:-18082}/actuator/health/liveness" >/dev/null; then exit 0; fi; sleep 2; done; exit 1`

**Résultat :** ✅ Test réussi

```text
curl: (56) Recv failure: Connection reset by peer
curl: (56) Recv failure: Connection reset by peer
```

</details>

<details>
<summary>10 — Partie 3 — Environnement Compose</summary>

**Commande :** `bash -c test "$(curl -sS "http://localhost:${MOVIE_PORT:-18080}/api/movies/whoami" | jq -r ".environment")" = "compose"`

**Résultat :** ✅ Test réussi

_Aucune sortie._

</details>

<details>
<summary>11 — Partie 3 — Réservation Compose</summary>

**Commande :** `bash -c curl -sS -X POST "http://localhost:${TICKET_PORT:-18082}/api/tickets" -H "Content-Type: application/json" -d "{\"movieId\":1,\"seats\":2}" | jq -e ".total == 21.00" >/dev/null`

**Résultat :** ✅ Test réussi

_Aucune sortie._

</details>

<details>
<summary>12 — Partie 4 — Namespace cinema-exam</summary>

**Commande :** `kubectl get namespace cinema-exam`

**Résultat :** ✅ Test réussi

```text
NAME          STATUS   AGE
cinema-exam   Active   77m
```

</details>

<details>
<summary>13 — Partie 4 — Validation des manifests Kubernetes</summary>

**Commande :** `kubectl apply --dry-run=client -f k8s/`

**Résultat :** ✅ Test réussi

```text
namespace/cinema-exam unchanged (dry run)
configmap/movie-config unchanged (dry run)
configmap/ticket-config unchanged (dry run)
deployment.apps/movie unchanged (dry run)
service/movie unchanged (dry run)
deployment.apps/ticket unchanged (dry run)
service/ticket unchanged (dry run)
ingress.networking.k8s.io/cinema unchanged (dry run)
```

</details>

<details>
<summary>14 — Partie 4 — Deployment movie disponible</summary>

**Commande :** `kubectl wait --for=condition=available deployment/movie -n cinema-exam --timeout=10s`

**Résultat :** ✅ Test réussi

```text
deployment.apps/movie condition met
```

</details>

<details>
<summary>15 — Partie 4 — Deployment ticket disponible</summary>

**Commande :** `kubectl wait --for=condition=available deployment/ticket -n cinema-exam --timeout=10s`

**Résultat :** ✅ Test réussi

```text
deployment.apps/ticket condition met
```

</details>

<details>
<summary>16 — Partie 4 — Endpoints movie disponibles</summary>

**Commande :** `bash -c test -n "$(kubectl get endpoints movie -n cinema-exam -o jsonpath="{.subsets[*].addresses[*].ip}")"`

**Résultat :** ✅ Test réussi

```text
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
```

</details>

<details>
<summary>17 — Partie 4 — Endpoints ticket disponibles</summary>

**Commande :** `bash -c test -n "$(kubectl get endpoints ticket -n cinema-exam -o jsonpath="{.subsets[*].addresses[*].ip}")"`

**Résultat :** ✅ Test réussi

```text
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
```

</details>

<details>
<summary>18 — Bonus B1 — UID movie égal à 10001</summary>

**Commande :** `bash -c test "$(kubectl exec -n cinema-exam deploy/movie -- id -u)" = "10001"`

**Résultat :** ✅ Test réussi

_Aucune sortie._

</details>

<details>
<summary>19 — Bonus B1 — Système de fichiers racine en lecture seule</summary>

**Commande :** `bash -c ! kubectl exec -n cinema-exam deploy/movie -- touch /test-bonus`

**Résultat :** ✅ Test réussi

```text
touch: cannot touch '/test-bonus': Read-only file system
command terminated with exit code 1
```

</details>

<details>
<summary>20 — Bonus B2 — Stratégie RollingUpdate</summary>

**Commande :** `bash -c test "$(kubectl get deployment movie -n cinema-exam -o jsonpath="{.spec.strategy.type}")" = "RollingUpdate"`

**Résultat :** ✅ Test réussi

_Aucune sortie._

</details>

<details>
<summary>21 — Bonus B2 — maxUnavailable égal à 0</summary>

**Commande :** `bash -c test "$(kubectl get deployment movie -n cinema-exam -o jsonpath="{.spec.strategy.rollingUpdate.maxUnavailable}")" = "0"`

**Résultat :** ✅ Test réussi

_Aucune sortie._

</details>

<details>
<summary>22 — Partie 5 — Port-forward Ingress actif</summary>

**Commande :** `bash -c [ "$(curl -sS -o /dev/null -w "%{http_code}" -H "Host: cinema.local" http://localhost:8088/api/movies)" = "200" ]`

**Résultat :** ✅ Test réussi

_Aucune sortie._

</details>

<details>
<summary>23 — Partie 5 — Liste des films via Ingress</summary>

**Commande :** `bash -c test "$(curl -sS -H "Host: cinema.local" http://localhost:8088/api/movies | jq -r "length")" -ge 4`

**Résultat :** ✅ Test réussi

_Aucune sortie._

</details>

<details>
<summary>24 — Partie 5 — Réservation via Ingress</summary>

**Commande :** `bash -c curl -sS -H "Host: cinema.local" -X POST http://localhost:8088/api/tickets -H "Content-Type: application/json" -d "{\"movieId\":3,\"seats\":10}" | jq -e ".total == 90.00" >/dev/null`

**Résultat :** ✅ Test réussi

_Aucune sortie._

</details>

<details>
<summary>25 — Partie 5 — Actuator non exposé par Ingress</summary>

**Commande :** `bash -c [ "$(curl -sS -o /dev/null -w "%{http_code}" -H "Host: cinema.local" http://localhost:8088/actuator/health)" = "404" ]`

**Résultat :** ✅ Test réussi

_Aucune sortie._

</details>
