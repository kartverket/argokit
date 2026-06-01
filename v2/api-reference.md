# ArgoKit v2 API

Denne referansen er organisert etter hvor API-et brukes:

| Område | Importsti | Brukes til |
|-|-|-|
| Application | `argokit.appAndObjects.application` | Skiperator `Application`-ressurser |
| SKIPJob | `argokit.appAndObjects.skipjob` | Skiperator `SKIPJob`-ressurser |
| Felles workload-hjelpere | `argokit.appAndObjects.<workload>` | hjelpere som finnes på både `application` og `skipjob` |
| Frittstående ressurser | `argokit.k8s.*`, `argokit.routing`, `argokit.externalSecrets.*`, `argokit.azureAdApplication` | Ressurser som rendres utenfor en appAndObjects-workload |

I seksjoner for felles hjelpere betyr `<workload>` enten `application` eller `skipjob`.

## Konstruktører

### `argokit.appAndObjects.application.new()`
Oppretter en Skiperator `Application` ved å bruke `appAndObjects`-konvensjonen.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `name` | `string` | `true` | - | navn på applikasjonen |
| `image` | `string` | `true` | - | container-image |
| `port` | `number` | `true` | - | hovedport for containeren |

Eksempel: [examples/application.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/application.jsonnet)

### `argokit.appAndObjects.skipjob.new()`
Oppretter en Skiperator `SKIPJob` med API-versjon `skiperator.kartverket.no/v1beta1`.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `name` | `string` | `true` | - | navn på jobben |
| `image` | `string` | `true` | - | container-image |

Eksempel: [examples/skipjob.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/skipjob.jsonnet)

## SKIPJob-hjelpere

### `argokit.appAndObjects.skipjob.withCron()`
Gjør SKIPJob periodisk ved å sette `spec.cron`. Se Kubernetes cron-syntaks [her](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#schedule-syntax).

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `schedule` | `string` | `true` | - | cron-uttrykk |
| `allowConcurrency` | `string` | `false` | - | `Allow`, `Forbid` eller `Replace` |
| `startingDeadlineSeconds` | `number` | `false` | - | frist i sekunder for å starte en forsinket jobb |
| `suspend` | `boolean` | `false` | - | suspenderer cronjobben |
| `timeZone` | `string` | `false` | - | IANA-tidssone, f.eks. `Europe/Oslo` |

### `argokit.appAndObjects.skipjob.withSettings()`
Setter Kubernetes Job-innstillinger under `spec.job`.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `activeDeadlineSeconds` | `number` | `false` | - | maks kjøretid i sekunder |
| `backoffLimit` | `number` | `false` | - | antall retry-forsøk før jobben regnes som feilet |
| `suspend` | `boolean` | `false` | - | suspenderer jobben |
| `ttlSecondsAfterFinished` | `number` | `false` | - | sekunder før ferdig jobb ryddes opp |

### `argokit.appAndObjects.skipjob.withRestartPolicy()`
Setter restart policy for jobben.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `restartPolicy` | `string` | `true` | - | `OnFailure` eller `Never` |

## Sammensatte maler

### `argokit.dbArchiveJob()`
Oppretter en `SKIPJob` v1beta1 som tar PostgreSQL-dump og lagrer den i S3, sammen med ExternalSecrets for database- og S3-hemmeligheter.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `instanceName` | `string` | `true` | - | navn på databaseinstansen og SKIPJob-ressursen |
| `schedule` | `string` | `true` | - | cron-uttrykk for arkiveringsjobben |
| `databaseIP` | `string` | `true` | - | IP-adresse til databasen |
| `gcpS3CredentialsSecret` | `string` | `true` | - | navn på hemmelighet med S3-credentials |
| `databaseName` | `string` | `true` | - | databasen som skal arkiveres |
| `archiveUser` | `string` | `false` | `postgres` | databasebrukeren jobben kobler til med |
| `serviceAccount` | `string` | `false` | `dummyaccount@iam.gserviceaccount.com` | GCP service account for Workload Identity |
| `cloudsqlInstanceConnectionName` | `string` | `true` | - | Cloud SQL connection name |
| `port` | `number` | `false` | `5432` | databaseport |
| `S3Host` | `string` | `false` | `s3-rin.statkart.no` | S3-endepunkt |
| `S3DestinationPath` | `string` | `true` | - | S3-sti der dumpen skal lagres |
| `fullDump` | `boolean` | `false` | `false` | om jobben også skal dumpe roller |

Eksempel: [examples/dbArchive.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/dbArchive.jsonnet)

## Application-hjelpere

### `argokit.appAndObjects.application.withReplicas()`
Setter replikaer for en `Application`, eventuelt med autoskalering.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `initial` | `number` | `true` | `2` | initialt antall replikaer |
| `max` | `number` | `false` | - | maksimalt antall replikaer. Aktiverer autoskalering når den er satt og ulik `initial` |
| `targetCpuUtilization` | `number` | `false` | - | CPU-terskel i prosent |
| `targetMemoryUtilization` | `number` | `false` | - | minne-terskel i prosent |

Eksempel: [examples/replicas.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/replicas.jsonnet)

### `argokit.appAndObjects.application.forHostnames()`
Oppretter ingress-oppføringer for en `Application`.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `ingress` | `array`, `string` eller `object` | `true` | - | hostname som string, liste med hostnames/objekter, eller `{ hostname, customCert }` |

Eksempel: [examples/ingress.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/ingress.jsonnet)

### `argokit.appAndObjects.application.withAzureAdApplication()`
Legger til en `AzureADApplication`-ressurs og konfigurerer applikasjonen til å bruke den.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `name` | `string` | `true` | - | navn på `AzureADApplication`-ressursen |
| `namespace` | `string` | `false` | - | namespace for ressursen |
| `groups` | `array` | `false` | `[]` | Azure AD-grupper for claims |
| `secretPrefix` | `string` | `false` | `azuread` | prefix for secret-navnet |
| `allowAllUsers` | `boolean` | `false` | `false` | om alle brukere skal få tilgang |
| `logoutUrl` | `string` | `false` | - | logout-URL |
| `replyUrls` | `array` | `false` | `[]` | reply URLs |
| `preAuthorizedApplications` | `array` | `false` | `[]` | forhåndsautoriserte applikasjoner |

Eksempel: [examples/withAzureAdApplication.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/withAzureAdApplication.jsonnet)

## Felles workload-hjelpere

Disse hjelperne finnes på både `argokit.appAndObjects.application` og `argokit.appAndObjects.skipjob`.

### Metadata og pod-innstillinger

| funksjon | beskrivelse |
|-|-|
| `withCommand(command)` | setter `spec.command` |
| `withLabels(labels)` | setter `spec.labels` |
| `withTeam(team)` | setter `spec.team` |
| `withPriority(priority)` | setter `spec.priority` til `low`, `medium` eller `high` |
| `withAdditionalPort(name, port, protocol='TCP')` | legger til en oppføring i `spec.additionalPorts` |
| `withPodSettings(...)` | setter `spec.podSettings` |
| `withTracing(randomSamplingPercentage)` | setter sampling-prosent for Istio tracing |

### `<workload>.resources.withRequests()`
Setter ressurskrav.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `cpu` | `string` eller `number` | `false` | - | CPU-krav, f.eks. `100m`, `0.5` eller `1` |
| `memory` | `string` eller `number` | `false` | - | minnekrav, f.eks. `128Mi` eller `1Gi` |

Eksempel: [examples/appWithResources.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/appWithResources.jsonnet)

### `<workload>.resources.withLimits()`
Setter ressursgrenser.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `cpu` | `string` eller `number` | `false` | - | CPU-grense, f.eks. `500m`, `1` eller `2.0` |
| `memory` | `string` eller `number` | `false` | - | minnegrense, f.eks. `512Mi` eller `2Gi` |

Eksempel: [examples/appWithResources.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/appWithResources.jsonnet)

### Miljøvariabler

| funksjon | beskrivelse |
|-|-|
| `withEnvironmentVariable(name, value)` | legger til én statisk miljøvariabel |
| `withEnvironmentVariables(pairs)` | legger til flere statiske miljøvariabler fra et objekt |
| `withEnvironmentVariableFromSecret(name, secretRef, key=name)` | legger til én miljøvariabel fra en Secret-nøkkel |
| `withEnvironmentVariablesFromSecret(secretName)` | legger til alle miljøvariabler fra en Secret |

Eksempel: [examples/environment.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/environment.jsonnet)

### Tilgangspolicyer

| funksjon | beskrivelse |
|-|-|
| `withOutboundPostgres(host, ip)` | tillater utgående PostgreSQL-trafikk |
| `withOutboundOracle(host, ip)` | tillater utgående Oracle-trafikk |
| `withOutboundSsh(host, ip)` | tillater utgående SSH-trafikk |
| `withOutboundLdaps(host, ip)` | tillater utgående LDAPS-trafikk |
| `withOutboundHttp(host, portname='', port=443, protocol='')` | tillater utgående HTTP/HTTPS-trafikk |
| `withOutboundSkipApp(appname, namespace='')` | tillater utgående trafikk til en annen SKIP Application |
| `withInboundSkipApp(appname, namespace='')` | tillater inngående trafikk fra en annen SKIP Application |

Eksempel: [examples/accessPolicies.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet)

### Prober

| funksjon | beskrivelse |
|-|-|
| `probe(path, port, failureThreshold=3, timeout=1, initialDelay=0)` | bygger et probe-objekt |
| `withReadiness(probe)` | setter `spec.readiness` |
| `withLiveness(probe)` | setter `spec.liveness` |
| `withStartup(probe)` | setter `spec.startup` |

Eksempel: [examples/probes.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/probes.jsonnet)

### `withPrometheus()`
Konfigurerer scraping av Prometheus-kompatible metrics.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `path` | `string` | `true` | - | sti for metrics, f.eks. `/metrics` |
| `port` | `number` | `true` | - | port for metrics |
| `allowAllMetrics` | `boolean` | `false` | `false` | hvis `true`, blir alle eksponerte metrics skrapet |
| `scrapeInterval` | `string` | `false` | `60s` | scrape-intervall, f.eks. `30s` eller `1m`; bruk tom string for å utelate feltet |

Eksempel: [examples/application-with-prometheus.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/application-with-prometheus.jsonnet)

### GCP

| funksjon | beskrivelse |
|-|-|
| `withGcpServiceAccount(serviceAccount)` | setter Workload Identity service account under `spec.gcp.auth` |
| `withCloudSqlProxy(connectionName, serviceAccount, ip, publicIP=null, version=null)` | konfigurerer Cloud SQL Auth Proxy under `spec.gcp.cloudSqlProxy` |

### ConfigMap-hjelpere

| funksjon | beskrivelse |
|-|-|
| `withConfigMapAsEnv(name, data, addHashToName=false)` | oppretter en ConfigMap og legger den til via `spec.envFrom` |
| `withConfigMapAsMount(name, mountPath, data, addHashToName=false)` | oppretter en ConfigMap og monterer den som filer |

Eksempel: [examples/withConfigMap.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/withConfigMap.jsonnet)

### ExternalSecret-hjelper

| funksjon | beskrivelse |
|-|-|
| `withEnvironmentVariablesFromExternalSecret(name, creationPolicy=null, secrets=[], allKeysFrom=[], secretStoreRef='gsm')` | oppretter en `ExternalSecret` og legger til miljøvariabler fra den resulterende Secret-en |

Eksempel: [examples/withExternalSecret.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/withExternalSecret.jsonnet)

### Monteringer

| funksjon | beskrivelse |
|-|-|
| `withSecretAsMount(secretName, mountPath)` | monterer en eksisterende Secret som filer |
| `withPersistentVolumeClaimAsMount(pvcName, mountPath)` | monterer en PVC |
| `withEmptyDirAsMount(mountPath, emptyDir)` | monterer et emptyDir-volum |

Eksempel: [examples/mounts.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/mounts.jsonnet)

### Ekstra objekter

| funksjon | beskrivelse |
|-|-|
| `withObjects(objects)` | legger til ett objekt eller en liste med objekter i rendret `List` |

Eksempel: [examples/additionalObjects.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/additionalObjects.jsonnet)

## Frittstående ressurser

### `argokit.routing.new()`
Bygger et `Routing`-objekt.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `name` | `string` | `true` | - | navn på routing-objektet |
| `hostname` | `string` | `true` | - | hostname |
| `redirectToHTTPS` | `boolean` | `false` | `true` | om trafikk skal videresendes til HTTPS |

### `argokit.routing.withRoute()`
Legger til en route i et `Routing`-objekt.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `pathPrefix` | `string` | `true` | - | route-prefix |
| `targetApp` | `string` | `true` | - | mål-Application |
| `rewriteUri` | `boolean` | `true` | - | om URI skal skrives om |
| `port` | `number` | `false` | `null` | målport |

Eksempel: [examples/routing.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/routing.jsonnet)

### `argokit.k8s.rolebinding.new()`
Oppretter en RoleBinding-ressurs. Utvid den med enten `withUsers()` eller `withNamespaceAdminGroup()`.

### `argokit.k8s.rolebinding.withUsers()`
Legger til brukere som subjects.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `users` | `array` | `true` | - | brukernavn |

### `argokit.k8s.rolebinding.withNamespaceAdminGroup()`
Legger til en namespace-admin-gruppe som subject.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `groupName` | `string` | `true` | - | gruppenavn |

Eksempel: [examples/rolebinding.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/rolebinding.jsonnet)

### `argokit.externalSecrets.secret.new()`
Oppretter en `ExternalSecret`.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `name` | `string` | `true` | - | navn på secret |
| `creationPolicy` | `string` | `false` | `null` | styrer `spec.target.creationPolicy`; utelates når den er `null` |
| `secrets` | `array` | `false` | `[]` | oppføringer med `toKey`, `fromSecret` og valgfrie conversion-/metadata-felt |
| `allKeysFrom` | `array` | `false` | `[]` | oppføringer med `fromSecret` for import av alle nøkler |
| `secretStoreRef` | `string` | `false` | `gsm` | navn på SecretStore |

Enten `secrets` eller `allKeysFrom` må inneholde minst ett element.

### `argokit.externalSecrets.store.new()`
Oppretter en ekstern `SecretStore`.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `name` | `string` | `false` | `gsm` | navn på store |
| `gcpProject` | `string` | `true` | - | GCP prosjekt-ID |

Eksempel: [examples/externalSecrets.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/externalSecrets.jsonnet)

### `argokit.k8s.configMap.new()`
Oppretter en ConfigMap.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `name` | `string` | `true` | - | navn på ConfigMap |
| `data` | `object` | `true` | - | data i ConfigMap |
| `addHashToName` | `boolean` | `false` | `false` | om hash-suffiks skal legges til navnet |

Eksempel: [examples/configMap.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/configMap.jsonnet)

### `argokit.azureAdApplication.new()`
Oppretter en frittstående `AzureADApplication`-ressurs.

| navn | type | obligatorisk | standardverdi | beskrivelse |
|-|-|-|-|-|
| `name` | `string` | `true` | - | navn på `AzureADApplication`-ressursen |
| `namespace` | `string` | `false` | - | namespace for ressursen |
| `groups` | `array` | `false` | `[]` | Azure AD-grupper for claims |
| `secretPrefix` | `string` | `false` | `azuread` | prefix for secret-navnet |
| `allowAllUsers` | `boolean` | `false` | `false` | om alle brukere skal få tilgang |
| `logoutUrl` | `string` | `false` | - | logout-URL |
| `replyUrls` | `array` | `false` | `[]` | reply URLs |
| `preAuthorizedApplications` | `array` | `false` | `[]` | forhåndsautoriserte applikasjoner |

Eksempel: [examples/newAzureAdApplication.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/newAzureAdApplication.jsonnet)
