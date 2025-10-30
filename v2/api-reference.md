# V2 API Reference

## Jsonnet ArgoKit API

| Funksjon | Argumenter | Beskrivelse | Eksempel |
|----------|-----------|-------------|----------|
| `argokit.appAndObjects.application.new()` | **name** (string): Navnet på applikasjonen<br>**image** (string): Image <br>**port** (number): Port som applikasjonen lytter på | Oppretter en ny Skiperator‑applikasjon ved å bruke appAndObjects‑konvensjonen. Dette er den standarde måten å opprette en applikasjon på. | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/application.jsonnet) |
| `argokit.appAndObjects.application.withObjects()` | **object** (object): Kubernetes-objekt som skal legges til | Legg til ekstra Kubernetes-objekter i "objects" listen til appAndObjects strukturen | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/additionalObjects.jsonnet) |

## ArgoKit's Replicas API

**OBS!** Det anbefales ikke å kjøre med færre enn 2 replikaer. Dette antallet er satt for at du skal ha god nok tilgjengelighet for applikasjonen din, med å legge til redundans.

| Funksjon | Argumenter | Beskrivelse | Eksempel |
|----------|-----------|-------------|----------|
| `argokit.appAndObjects.application.withReplicas()` | **initial** (number): Antall replikaer ved oppstart (minimum 2 anbefales)<br>**max** (number, valgfri): Maksimalt antall replikaer. Hvis satt og ulik initial, aktiveres autoskalering<br>**targetCpuUtilization** (number, default=80): CPU-utnyttelse (%) før oppskalering<br>**targetMemoryUtilization** (number, valgfri): Minneutnyttelse (%) før oppskalering | Konfigurer replikaer for applikasjonen. Kan settes som statisk antall (initial=max) eller med autoskalering basert på CPU og minne | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/replicas.jsonnet) |


## ArgoKit's Environment API

| Funksjon | Argumenter | Beskrivelse | Eksempel |
|----------|-----------|-------------|----------|
| `argokit.appAndObjects.application.withEnvironmentVariable()` | **name** (string): Navnet på miljøvariabelen<br>**value** (string): Verdien til miljøvariabelen | Oppretter en enkelt miljøvariabel med en statisk verdi | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/environment.jsonnet) |
| `argokit.appAndObjects.application.withEnvironmentVariables()` | **pairs** (object): Map med nøkkel-verdi par av miljøvariabler | Oppretter flere miljøvariabler samtidig med statiske verdier | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/environment.jsonnet) |
| `argokit.appAndObjects.application.withEnvironmentVariableFromSecret()` | **name** (string): Navnet på miljøvariabelen<br>**secretRef** (string): Navnet på secret-ressursen<br>**key** (string, valgfri): Nøkkelen i secreten (default: samme som name) | Oppretter en miljøvariabel som henter verdien fra en Kubernetes secret | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/environment.jsonnet) |
| `argokit.appAndObjects.application.withEnvironmentVariablesFromSecret()` | **secretName** (string): Navnet på secret-ressursen | Importerer alle nøkler fra en secret som miljøvariabler | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/environment.jsonnet) |

---

## ArgoKit's Ingress API

| Funksjon | Argumenter | Beskrivelse | Eksempel |
|----------|-----------|-------------|----------|
| `argokit.appAndObjects.application.forHostnames()` | **ingress** (array): Liste med hostname strings eller objekter med `{hostname: string, customCert?: string}` | Oppretter ingress(er) for applikasjonen. Kan ta både enkle hostname strings eller objekter med custom sertifikater | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/ingress.jsonnet) |

## ArgoKit's accessPolicies API

Du kan definere hvilke eksterne tjenester (verter/IP‑er) og interne SKIP‑applikasjoner appen din kan kommunisere med.

| Funksjon | Argumenter | Beskrivelse | Eksempel |
|----------|-----------|-------------|----------|
| `argokit.appAndObjects.application.withOutboundPostgres()` | **host** (string): Hostname til Postgres-instansen<br>**ip** (string): IP-adresse til Postgres-instansen | Tillat utgående trafikk til en Postgres‑database på port 5432 | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withOutboundOracle()` | **host** (string): Hostname til Oracle-instansen<br>**ip** (string): IP-adresse til Oracle-instansen | Tillat utgående trafikk til en Oracle‑database på port 1521 | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withOutboundSsh()` | **host** (string): Hostname til SSH-serveren<br>**ip** (string): IP-adresse til SSH-serveren | Tillat utgående SSH-trafikk på port 22 | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withOutboundLdaps()` | **host** (string): Hostname til LDAPS-serveren<br>**ip** (string): IP-adresse til LDAPS-serveren | Tillat utgående sikker LDAP‑trafikk på port 636 | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withOutboundHttp()` | **host** (string): Hostname til HTTP(S)-serveren<br>**portname** (string, valgfri): Navn på porten<br>**port** (number, default=443): Portnummer<br>**protocol** (string, valgfri): Protokoll | Tillat utgående HTTP/HTTPS-trafikk til en ekstern vert | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withOutboundSkipApp()` | **appname** (string): Navnet på target-applikasjonen<br>**namespace** (string, valgfri): Namespace til target-applikasjonen | Tillat utgående trafikk til en annen SKIP‑applikasjon i samme eller annet namespace | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withInboundSkipApp()` | **appname** (string): Navnet på kilde-applikasjonen<br>**namespace** (string, valgfri): Namespace til kilde-applikasjonen | Tillat en annen SKIP‑applikasjon å nå denne applikasjonen | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |

## ArgoKit's Probe API

Konfigurer helseprober for applikasjoner.

| Funksjon | Argumenter | Beskrivelse | Eksempel |
|----------|-----------|-------------|----------|
| `argokit.appAndObjects.application.probe()` | **path** (string): Stien til health endpoint<br>**port** (number): Portnummeret<br>**failureThreshold** (number, default=3): Antall feilede forsøk før probe feiler<br>**timeout** (number, default=1): Timeout i sekunder<br>**initialDelay** (number, default=0): Forsinkelse i sekunder før første probe | Bygger et probe‑objekt som kan brukes med readiness, liveness eller startup | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/probes.jsonnet) |
| `argokit.appAndObjects.application.withReadiness()` | **probe** (object): Probe-objekt opprettet med `probe()` | Legger til en readiness‑probe som styrer når trafikk sendes til poden | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/probes.jsonnet) |
| `argokit.appAndObjects.application.withLiveness()` | **probe** (object): Probe-objekt opprettet med `probe()` | Legger til en liveness‑probe som restarter containeren ved feil | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/probes.jsonnet) |
| `argokit.appAndObjects.application.withStartup()` | **probe** (object): Probe-objekt opprettet med `probe()` | Legger til en startup‑probe som blokkerer andre prober til den lykkes | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/probes.jsonnet) |

## ArgoKit's routing API

Konfigurer ruting for applikasjoner på SKIP.

| Funksjon | Argumenter | Beskrivelse | Eksempel |
|----------|-----------|-------------|----------|
| `argokit.routing.new()` | **name** (string): Navnet på routing-ressursen<br>**hostname** (string): Hostname for ruten<br>**redirectToHTTPS** (boolean, default=true): Om trafikk skal redirectes til HTTPS | Bygger et rute‑objekt | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/routing.jsonnet) |
| `argokit.routing.withRoute()` | **pathPrefix** (string): Sti-prefix for ruten<br>**targetApp** (string): Navn på target-applikasjonen<br>**rewriteUri** (boolean): Om URI skal reskrives<br>**port** (number, valgfri): Port på target-applikasjonen | Legg til rute i rute‑objektet | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/routing.jsonnet) |

## ArgoKit's Rolebinding API

Konfigurer rolebinding‑ressurser for applikasjoner på SKIP. Opprett ressursen med funksjonen `new()`, og legg deretter til enten brukere eller en gruppe som subject.

| Funksjon | Argumenter | Beskrivelse | Eksempel |
|----------|-----------|-------------|----------|
| `argokit.k8s.rolebinding.new()` | Ingen | Opprett en ny rolebinding‑ressurs | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/rolebinding.jsonnet) |
| `argokit.k8s.rolebinding.withUsers()` | **users** (array): Liste med brukere (e-postadresser) | Legg til en liste over brukere som subjects | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/rolebinding.jsonnet) |
| `argokit.k8s.rolebinding.withNamespaceAdminGroup()` | **groupName** (string): Navnet på gruppen | Legg til en namespace‑admin‑gruppe som subject | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/rolebinding.jsonnet) |

## ArgoKit's ExternalSecret API

Konfigurer eksterne secrets og stores.

| Funksjon | Argumenter | Beskrivelse | Eksempel |
|----------|-----------|-------------|----------|
| `argokit.externalSecrets.secret.new()` | **name** (string): Navnet på secreten<br>**secrets** (array, default=[]): Liste med secret-mappinger `[{fromSecret: string, toKey: string}]`<br>**allKeysFrom** (array, default=[]): Liste med secrets hvor alle keys importeres `[{fromSecret: string}]`<br>**secretStoreRef** (string, default='gsm'): Referanse til secret store | Opprett en ny ekstern secret. Må ha enten secrets eller allKeysFrom | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/externalSecrets.jsonnet) |
| `argokit.externalSecrets.store.new()` | **name** (string, default='gsm'): Navnet på secret store<br>**gcpProject** (string): GCP project ID | Opprett en ny ekstern store for Google Secret Manager | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/externalSecrets.jsonnet) |

## ArgoKit's ConfigMap API

Konfigurer ConfigMap‑ressurser for applikasjoner på SKIP.
Alle metoder har parameteren `addHashToName` for å opprette ConfigMap med et unikt navn (hashet suffiks).

| Funksjon | Argumenter | Beskrivelse | Eksempel |
|----------|-----------|-------------|----------|
| `argokit.k8s.configMap.new()` | **name** (string): Navnet på ConfigMapen<br>**data** (object): Data som skal lagres i ConfigMapen<br>**addHashToName** (boolean, default=false): Legg til hash i navnet | Opprett en ny ConfigMap | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/configMap.jsonnet) |
| `argokit.appAndObjects.application.withConfigMapAsEnv()` | **name** (string): Navnet på ConfigMapen<br>**data** (object): Data som skal lagres<br>**addHashToName** (boolean, default=false): Legg til hash i navnet | Opprett en ny ConfigMap og legg innholdet som env i applikasjonen | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/withConfigMap.jsonnet) |
| `argokit.appAndObjects.application.withConfigMapAsMount()` | **name** (string): Navnet på ConfigMapen<br>**mountPath** (string): Sti hvor ConfigMapen skal monteres<br>**data** (object): Data som skal lagres<br>**addHashToName** (boolean, default=false): Legg til hash i navnet | Opprett en ny ConfigMap og monter den som en fil i applikasjonens filsystem | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/withConfigMap.jsonnet) |

## ArgoKit's Azure AD API

Konfigurer en ny Azure AD applikasjon eller legg til en Azure AD applikasjon til din eksisterende applikasjon.

| Funksjon | Argumenter | Beskrivelse | Eksempel |
|----------|-----------|-------------|----------|
| `argokit.azureAdApplication.new()` | **name** (string): Navnet på Azure AD applikasjonen<br>**namespace** (string, valgfri): Namespace for applikasjonen<br>**groups** (array, default=[]): Liste med Azure AD gruppe-IDer<br>**secretPrefix** (string, default='azuread'): Prefix for secret-navnet<br>**allowAllUsers** (boolean, default=false): Om alle brukere skal ha tilgang<br>**logoutUrl** (string, valgfri): URL for logout<br>**replyUrls** (array, default=[]): Liste med reply URLs<br>**preAuthorizedApplications** (array, default=[]): Liste med pre-autoriserte applikasjoner | Opprett en ny standalone Azure AD applikasjon | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/newAzureAdApplication.jsonnet) |
| `argokit.appAndObjects.application.withAzureAdApplication()` | **name** (string): Navnet på Azure AD applikasjonen<br>**namespace** (string, valgfri): Namespace for applikasjonen<br>**groups** (array, default=[]): Liste med Azure AD gruppe-IDer<br>**secretPrefix** (string, default='azuread'): Prefix for secret-navnet<br>**allowAllUsers** (boolean, default=false): Om alle brukere skal ha tilgang<br>**logoutUrl** (string, valgfri): URL for logout<br>**replyUrls** (array, default=[]): Liste med reply URLs<br>**preAuthorizedApplications** (array, default=[]): Liste med pre-autoriserte applikasjoner | Legg til Azure AD applikasjon til en eksisterende applikasjon. Setter automatisk opp miljøvariabler fra secret og tillater utgående trafikk til login.microsoftonline.com | [Se eksempel](https://github.com/kartverket/argokit/blob/main/v2/examples/withAzureAdApplication.jsonnet) |


