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

argokit.application.new('foo-backend')
+argokit.application.withReplicas(initial=2, max=5, targetCpuUtilization=80)
+argokit.application.forHostnames('foo.bar.com')
+argokit.application.withInboundSkipApp('foo-frontend')
```

### jsonnet argokit API

The following examples are available at [our github](https://github.com/kartverket/argokit/v2/examples)


| Template                    | Description                                                           | Example                                                                                    |
|-----------------------------|-----------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| `argokit.application.new()` | Creates a Skiperator application, using the appAndObjects convention (this is default).| See above                                                                                  |
| `argokit.skipJob.new()` | Creates a Skiperator job, using the appAndObjects convention. | [examples/accessPolicies-for-job.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies-for-job.jsonnet)|
### argoKit's Replicas API
**NOTE!** It is not recommended to run with less than 2 replicas... 
| Template                                | Description                                                     | Example                                                                                    |
|-----------------------------------------|-----------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| `argokit.application.withReplicas`   | Create replicas for an application with sensible defaults  | [examples/replicas.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/replicas.jsonnet)               |
| `argokit.application.withReplicas`   | Create replicas for an application with memory monitoring  | [examples/replicasets-with-memory.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/replicas-with-memory.jsonnet)   |
| `argokit.application.withReplicas`   | Creates a static replica without cpu- and memory monitoring | [examples/replicasets-static.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/replicas-static.jsonnet) |


### argoKit's Environment API

| Template                                              | Description                                                    | Example                                                                  |
|-------------------------------------------------------|----------------------------------------------------------------|--------------------------------------------------------------------------|
| `argokit.[application\|skipJOB].withVariable`         | Creates environment variables for an app                       | [examples/envVariables.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/envVariables.jsonnet) |
| `argokit.[application\|skipJOB].withVariableSecret`   | Creates environment variable from a secret                     | [examples/envVariables.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/envVariables.jsonnet) |
| `argokit.[application\|skipJOB].withVariableSecret`   | Creates environment variable from a secret for a Job container | [examples/envVariables.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/envVariables.jsonnet) |

---
### argoKit's Ingress API

| Template                                              | Description                                                    | Example                                                                  |
|-------------------------------------------------------|----------------------------------------------------------------|--------------------------------------------------------------------------|
| `argokit.application.forHostname`         | Creates ingress for an app or a job                       | [examples/ingress.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/ingress.jsonnet) |


### argoKit's accessPolicies API

You can define what external services (hosts/IPs) and internal SKIP applications your app or job may communicate with.  
All functions work for both applications and skipJobs: `argokit.application.*` or `argokit.skipJob.*`.

| Template                                                          | Description                                                                 | Example |
|-------------------------------------------------------------------|-----------------------------------------------------------------------------|---------|
| `argokit.[application\|skipJob].withOutboundPostgres(host, ip)`   | Allow outbound traffic to a Postgres instance           | [examples/accessPolicies-for-job.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies-for-job.jsonnet) |
| `argokit.[application\|skipJob].withOutboundOracle(host, ip)`     | Allow outbound traffic to an Oracle DB                       | [examples/accessPolicies-for-job.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies-for-job.jsonnet) |
| `argokit.[application\|skipJob].withOutboundSsh(host, ip)`        | Allow outbound SSH                                    | [examples/accessPolicies-for-job.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies-for-job.jsonnet) |
| `argokit.[application\|skipJob].withOutboundLdaps(host, ip)`      | Allow outbound secure LDAP port                                   | [examples/accessPolicies-for-job.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies-for-job.jsonnet) |
| `argokit.[application\|skipJob].withOutboundHttp(host, portname='', port=443, protocol='')` | Allow outbound HTTPS/HTTP to a host | [examples/accessPolicies-for-job.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies-for-job.jsonnet) |
| `argokit.[application\|skipJob].withOutboundSkipApp(appname, namespace='')` | Allow outbound traffic to another SKIP application (outbound rule) | [examples/accessPolicies-for-job.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies-for-job.jsonnet) |
| `argokit.[application\|skipJob].withInboundSkipApp(appname, namespace='')`  | Allow another SKIP application to reach this one (inbound rule) | [examples/accessPolicies-for-job.jsonnet](https://github.com/kartverket/argokit/blob/main/v2/examples/accessPolicies-for-job.jsonnet) |
### argoKit's Probe API
Configure health probes for applications and skipJobs.

| Template                                                                 | Description                                                            | Example |
|--------------------------------------------------------------------------|------------------------------------------------------------------------|---------|
| `argokit.[application\|skipJob].probe(path, port, failureThreshold=3, timeout=1, initialDelay=0)` | Builds a probe object (path, port, thresholds)                         | - |
| `argokit.[application\|skipJob].withReadiness(probe)`                    | Adds a readiness probe (controls when traffic is sent to the pod)      |[examples/probes](https://github.com/kartverket/argokit/blob/main/v2/examples/probes.jsonnet)|
| `argokit.[application\|skipJob].withLiveness(probe)`                     | Adds a liveness probe (restarts container if failing)                  | [examples/probes](https://github.com/kartverket/argokit/blob/main/v2/examples/probes.jsonnet) |
| `argokit.[application\|skipJob].withStartup(probe)`                      | Adds a startup probe (gates other probes until it succeeds)            | [examples/probes](https://github.com/kartverket/argokit/blob/main/v2/examples/probes.jsonnet) |

## Contributing

Contributions are welcome! Please open an issue or PR if you would like to
see something changed or added.

## License

ArgoKit is licensed under the MIT License. See [LICENSE](https://github.com/kartverket/argokit/blob/main/LICENSE) for the full
license text.
