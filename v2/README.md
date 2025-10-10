# ArgoKit v2

<p align="center">
<img src="logo.png" alt="ArgoKit Logo" width="300px" />
</p>

ArgoKit v2 is a set of reusable jsonnet templates, building on the old argoKit, that makes it easier to deploy
ArgoCD applications on SKIP. It is a work in progress and will be updated as we
learn more about how to best deploy with ArgoCD on SKIP. If you have any
questions, please reach out to the #gen-argocd or #spire-kartverket-devex-sparring channels in Slack.

## Installation

Assuming you have followed the [Getting Started](https://kartverket.atlassian.net/wiki/spaces/SKIPDOK/pages/554827836/Komme+i+gang+med+Argo+CD)
guide, you can use ArgoKit in your apps-repo.

First you need to install jsonnet bundler. This is done by running `brew install jsonnet-bundler` or download the
[binary release](https://github.com/jsonnet-bundler/jsonnet-bundler).
Next run `jb init`, and finally run `jb install github.com/kartverket/argokit@main`. If you want
to stay on a specific version use `jb install github.com/kartverket/argokit@2.0.0`

Remember to add `vendor/` to .gitignore

### Git submodules
Alternatively you can use submodules if you prefer it over jsonnet bundler (We recommend jsonnet bundler).
Include the ArgoKit library by running the following command:

```bash
$ git submodule add https://github.com/kartverket/argokit.git
```

### Automatic version updates

It is highly recommended to use dependabot to automatically update the ArgoKit
version when a new version is released. To do this, add the following to your
`.github/dependabot.yml` file:


```yaml
version: 2
updates:
  - package-ecosystem: gitsubmodule
    directory: /
    schedule:
      interval: daily
```

With this configuration, dependabot will automatically create a PR to update the
ArgoKit version once a day provided that a new version has been released.

## Usage

If you use jsonnet in your apps-repo, you can use the ArgoKit library to deploy
ArgoCD applications by including the `argokit.libsonnet` file in your jsonnet
file and calling the `argokit.Application` function. For example, to deploy an
application, you can use the following jsonnet file:

```jsonnet
local argokit = import 'github.com/kartverket/argokit/v2/jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;
application.new('foo-backend')
 + application.withReplicas(initial=2, max=5, targetCpuUtilization=80)
 + application.forHostnames('foo.bar.com')
 + application.withInboundSkipApp('foo-frontend')
```

### jsonnet argokit API

The following examples are available at [our github](https://github.com/kartverket/argokit/v2/examples)


| Template                    | Description                                                           | Example                                                                                    |
|-----------------------------|-----------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| `argokit.appAndObjects.application.new()` | Creates a Skiperator application, using the appAndObjects convention (this is default).| See above                                                                                  |

### argoKit's Replicas API
**NOTE!** It is not recommended to run with less than 2 replicas...
| Template                                | Description                                                     | Example                                                                                    |
|-----------------------------------------|-----------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| `argokit.appAndObjects.application.withReplicas`   | Create replicas for an application with sensible defaults  | [examples/replicas.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/replicas.jsonnet)               |
| `argokit.appAndObjects.application.withReplicas`   | Create replicas for an application with memory monitoring  | [examples/replicasets-with-memory.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/replicas-with-memory.jsonnet)   |
| `argokit.appAndObjects.application.withReplicas`   | Creates a static replica without cpu- and memory monitoring | [examples/replicasets-static.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/replicas-static.jsonnet) |


### argoKit's Environment API

| Template                                              | Description                                                    | Example                                                                  |
|-------------------------------------------------------|----------------------------------------------------------------|--------------------------------------------------------------------------|
| `argokit.appAndObjects.application.withEnvironmentVariable`         | Creates environment variables for an app                       | [examples/environment.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/environment.jsonnet) |
| `argokit.appAndObjects.application.withEnvironmentVariables`         | Creates mutliple environment variables for an app                       | [examples/environment.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/environment.jsonnet) |
| `argokit.appAndObjects.application.withEnvironmentVariableFromSecret`   | Creates environment variable from a secret                     | [examples/environment.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/environment.jsonnet) |
| `argokit.appAndObjects.application.withEnvironmentVariableFromSecret`   | Creates environment variable from a secret | [examples/environment.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/environment.jsonnet) |

---
### argoKit's Ingress API

| Template                                              | Description                                                    | Example                                                                  |
|-------------------------------------------------------|----------------------------------------------------------------|--------------------------------------------------------------------------|
| `argokit.appAndObjects.application.forHostname`         | Creates ingress for an app.                      | [examples/ingress.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/ingress.jsonnet) |


### argoKit's accessPolicies API

You can define what external services (hosts/IPs) and internal SKIP applications your app may communicate with.

| Template                                                          | Description                                                                 | Example |
|-------------------------------------------------------------------|-----------------------------------------------------------------------------|---------|
| `argokit.appAndObjects.application.withOutboundPostgres(host, ip)`   | Allow outbound traffic to a Postgres instance           | [examples/accessPolicies.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withOutboundOracle(host, ip)`     | Allow outbound traffic to an Oracle DB                       | [examples/accessPolicies.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withOutboundSsh(host, ip)`        | Allow outbound SSH                                    | [examples/accessPolicies.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withOutboundLdaps(host, ip)`      | Allow outbound secure LDAP port                                   | [examples/accessPolicies.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withOutboundHttp(host, portname='', port=443, protocol='')` | Allow outbound HTTPS/HTTP to a host | [examples/accessPolicies.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withOutboundSkipApp(appname, namespace='')` | Allow outbound traffic to another SKIP application (outbound rule) | [examples/accessPolicies.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
| `argokit.appAndObjects.application.withInboundSkipApp(appname, namespace='')`  | Allow another SKIP application to reach this one (inbound rule) | [examples/accessPolicies.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies.jsonnet) |
### argoKit's Probe API
Configure health probes for applications.

| Template                                                                 | Description                                                            | Example |
|--------------------------------------------------------------------------|------------------------------------------------------------------------|---------|
| `argokit.appAndObjects.application.probe(path, port, failureThreshold=3, timeout=1, initialDelay=0)` | Builds a probe object (path, port, thresholds)                         | - |
| `argokit.appAndObjects.application.withReadiness(probe)`                    | Adds a readiness probe (controls when traffic is sent to the pod)      |[examples/probes](https://github.com/kartverket/argokit/blob/main/v2/examples/probes.jsonnet)|
| `argokit.appAndObjects.application.withLiveness(probe)`                     | Adds a liveness probe (restarts container if failing)                  | [examples/probes](https://github.com/kartverket/argokit/blob/main/v2/examples/probes.jsonnet) |
| `argokit.appAndObjects.application.withStartup(probe)`                      | Adds a startup probe (gates other probes until it succeeds)            | [examples/probes](https://github.com/kartverket/argokit/blob/main/v2/examples/probes.jsonnet) |


### argoKit's routing API
Configure routing for applications on SKIP.

| Template                                                                 | Description                                                            | Example |
|--------------------------------------------------------------------------|------------------------------------------------------------------------|---------|
| `argokit.routing.new(name, hostname, redirectToHTTPS)` | Builds a route object                                                                    | [examples/routing.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/routing.jsonnet) |
| `argokit.routing.withRoute(pathPrefix, targetApp, rewriteUri, port)` | Add route to the routes object                                             | [examples/routing.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/routing.jsonnet) |


## argokit's Rolebinding API
Configure rolebinding resources for applications on SKIP. Create the resource with the `new()` function, then add either users or a group as the subject.
| template | Description |Example |
|---|---|---|
|argokit.k8s.rolebinding.new()| Create a new rolebinding resource| [examples/rolebinding.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/rolebinding.jsonnet)|
|argokit.k8s.rolebinding.withUsers(users)| Add a list of users as subjects | [examples/rolebinding.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/rolebinding.jsonnet)|
|argokit.k8s.rolebinding.withNamespaceAdminGroup(groupname)| Add a namespace‑admin group as a subject | [examples/rolebinding.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/rolebinding.jsonnet)|


## argokit's ConfigMap API
Configure ConfigMap resources for applications on SKIP.
All methods have the `addHashToName` parameter to create the ConfigMap with a unique name (hashed suffix).
| template | Description |Example |
|---|---|---|
|argokit.k8s.configMap.new(name, data, addHashToName)| Create a new ConfigMap | [examples/configMap.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/configMap.jsonnet)|
|argokit.appAndObjects.application.withConfigMapAsEnv(name, data, addHashToName)| Create a new ConfigMap and add its content as env in the application | [examples/withConfigMap.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/withConfigMap.jsonnet)|
|argokit.appAndObjects.application.withConfigMapAsMount(name, mountPath, data, addHashToName)| Create a new ConfigMap and mount it as a file in the application's file system | [examples/withConfigMap.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/withConfigMap.jsonnet)|

## Contributing

Contributions are welcome! Please open an issue or PR if you would like to
see something changed or added.

## License

ArgoKit is licensed under the MIT License. See [LICENSE](https://github.com/kartverket/argokit/blob/main/LICENSE) for the full
license text.
