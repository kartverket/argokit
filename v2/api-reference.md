# V2 API Reference

## jsonnet ArgoKit API

| Funksjon                    | Beskrivelse                                                           | Eksempel                                                                                    |
|-----------------------------|-----------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| `argokit.appAndObjects.application.new()` | Oppretter en Skiperator‑applikasjon ved å bruke appAndObjects‑konvensjonen (dette er standard). | Se over                                                                                  |
| `argokit.appAndObjects.application.withObjects()` | Legg til ekstra objekter i 'objects' listen til appAndObjects strukturen| [examples/additionalObjects.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/additionalObjects.jsonnet)|

## ArgoKit's Replicas API

**NOTE!** Det anbefales ikke å kjøre med færre enn 2 replikaer...

| Funksjon                                | Beskrivelse                                                     | Eksempel                                                                                    |
|-----------------------------------------|-----------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| `argokit.appAndObjects.application.withReplicas`   | Sett replikaer for en applikasjon med fornuftige standardverdier | [examples/replicas.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/replicas.jsonnet) |
| `argokit.appAndObjects.application.withReplicas`   | Sett replikaer for en applikasjon med autoskalering basert på CPU og minne        | [examples/replicasets-with-memory.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/replicas-with-memory.jsonnet) |
| `argokit.appAndObjects.application.withReplicas`   | Sett en statisk replika uten autoskalering (ingen CPU- eller minnebasert skalering)       | [examples/replicasets-static.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/replicas-static.jsonnet) |

## ArgoKit's Environment API

| Funksjon                                              | Beskrivelse                                                    | Eksempel                                                                  |
|-------------------------------------------------------|----------------------------------------------------------------|--------------------------------------------------------------------------|
| `argokit.appAndObjects.application.withEnvironmentVariable`         | Oppretter miljøvariabler for en app                            | [examples/environment.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/environment.jsonnet) |
| `argokit.appAndObjects.application.withEnvironmentVariables`        | Oppretter flere miljøvariabler for en app                      | [examples/environment.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/environment.jsonnet) |
| `argokit.appAndObjects.application.withEnvironmentVariableFromSecret`   | Oppretter miljøvariabel fra en secret                          | [examples/environment.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/environment.jsonnet) |
| `argokit.appAndObjects.application.withEnvironmentVariablesFromSecret`   | Oppretter miljøvariabler fra en secret                          | [examples/environment.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/environment.jsonnet) |

---

## ArgoKit's Ingress API

| Funksjon                                              | Beskrivelse                                                    | Eksempel                                                                  |
|-------------------------------------------------------|----------------------------------------------------------------|--------------------------------------------------------------------------|
| `argokit.appAndObjects.application.forHostname`       | Oppretter ingress for en app                                   | [examples/ingress.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/ingress.jsonnet) |

## ArgoKit's accessPolicies API

Du kan definere hvilke eksterne tjenester (verter/IP‑er) og interne SKIP‑applikasjoner appen din kan kommunisere med.

| Funksjon                                                          | Beskrivelse                                                                 | Eksempel |
|-------------------------------------------------------------------|-----------------------------------------------------------------------------|---------|
| `argokit.appAndObjects.application.withOutboundPostgres(host, ip)`   | Tillat utgående trafikk til en Postgres‑instans                             | [examples/accessPolicies.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withOutboundOracle(host, ip)`     | Tillat utgående trafikk til en Oracle‑database                              | [examples/accessPolicies.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withOutboundSsh(host, ip)`        | Tillat utgående SSH                                                          | [examples/accessPolicies.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withOutboundLdaps(host, ip)`      | Tillat utgående sikker LDAP‑port                                            | [examples/accessPolicies.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withOutboundHttp(host, portname='', port=443, protocol='')` | Tillat utgående HTTPS/HTTP til en vert                                       | [examples/accessPolicies.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withOutboundSkipApp(appname, namespace='')` | Tillat utgående trafikk til en annen SKIP‑applikasjon (utgående regel)       | [examples/accessPolicies.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withInboundSkipApp(appname, namespace='')`  | Tillat en annen SKIP‑applikasjon å nå denne (inngående regel)                | [examples/accessPolicies.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |

## ArgoKit's Probe API

Konfigurer helseprober for applikasjoner.

| Funksjon                                                                 | Beskrivelse                                                            | Eksempel |
|--------------------------------------------------------------------------|------------------------------------------------------------------------|---------|
| `argokit.appAndObjects.application.probe(path, port, failureThreshold=3, timeout=1, initialDelay=0)` | Bygger et probe‑objekt (sti, port, terskler)                           | - |
| `argokit.appAndObjects.application.withReadiness(probe)`                 | Legger til en readiness‑probe (styrer når trafikk sendes til poden)    | [examples/probes](https://github.com/kartverket/argokit/blob/main/v2/examples/probes.jsonnet) |
| `argokit.appAndObjects.application.withLiveness(probe)`                  | Legger til en liveness‑probe (restarter container ved feil)            | [examples/probes](https://github.com/kartverket/argokit/blob/main/v2/examples/probes.jsonnet) |
| `argokit.appAndObjects.application.withStartup(probe)`                   | Legger til en startup‑probe (blokkerer andre prober til den lykkes)    | [examples/probes](https://github.com/kartverket/argokit/blob/main/v2/examples/probes.jsonnet) |

## ArgoKit's routing API

Konfigurer ruting for applikasjoner på SKIP.

| Funksjon                                                                 | Beskrivelse                                                            | Eksempel |
|--------------------------------------------------------------------------|------------------------------------------------------------------------|---------|
| `argokit.routing.new(name, hostname, redirectToHTTPS)`                   | Bygger et rute‑objekt                                                  | [examples/routing.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/routing.jsonnet) |
| `argokit.routing.withRoute(pathPrefix, targetApp, rewriteUri, port)`     | Legg til rute i rute‑objektet                                          | [examples/routing.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/routing.jsonnet) |

## ArgoKit's Rolebinding API

Konfigurer rolebinding‑ressurser for applikasjoner på SKIP. Opprett ressursen med funksjonen `new()`, og legg deretter til enten brukere eller en gruppe som subject.

| template | Beskrivelse | Eksempel |
|---|---|---|
| `argokit.k8s.rolebinding.new()` | Opprett en ny rolebinding‑ressurs | [examples/rolebinding.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/rolebinding.jsonnet) |
| `argokit.k8s.rolebinding.withUsers(users)` | Legg til en liste over brukere som subjects | [examples/rolebinding.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/rolebinding.jsonnet) |
| `argokit.k8s.rolebinding.withNamespaceAdminGroup(groupname)` | Legg til en namespace‑admin‑gruppe som subject | [examples/rolebinding.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/rolebinding.jsonnet) |

## ArgoKit's ExternalSecret API

Konfigurer eksterne secrets og stores.

| template | Beskrivelse | Eksempel |
|---|---|---|
| `argokit.externalSecrets.secret.new()` | Opprett en ny ekstern secret | [examples/externalSecrets.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/externalSecrets.jsonnet) |
| `argokit.externalSecrets.store.new()` | Opprett en ny ekstern store | [examples/externalSecrets.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/externalSecrets.jsonnet) |

## ArgoKit's ConfigMap API

Konfigurer ConfigMap‑ressurser for applikasjoner på SKIP.
Alle metoder har parameteren `addHashToName` for å opprette ConfigMap med et unikt navn (hashet suffiks).

| template | Beskrivelse | Eksempel |
|---|---|---|
| `argokit.k8s.configMap.new(name, data, addHashToName)` | Opprett en ny ConfigMap | [examples/configMap.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/configMap.jsonnet) |
| `argokit.appAndObjects.application.withConfigMapAsEnv(name, data, addHashToName)` | Opprett en ny ConfigMap og legg innholdet som env i applikasjonen | [examples/withConfigMap.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/withConfigMap.jsonnet) |
| `argokit.appAndObjects.application.withConfigMapAsMount(name, mountPath, data, addHashToName)` | Opprett en ny ConfigMap og monter den som en fil i applikasjonens filsystem | [examples/withConfigMap.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/withConfigMap.jsonnet) |
