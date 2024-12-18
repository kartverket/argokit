# ArgoKit

<p align="center">
<img src="logo.png" alt="ArgoKit Logo" width="300px" />
</p>

ArgoKit is a set of reusable jsonnet templates that makes it easier to deploy
ArgoCD applications on SKIP. It is a work in progress and will be updated as we
learn more about how to best deploy with ArgoCD on SKIP. If you have any
questions, please reach out to the #gen-argocd channel in Slack.

## Installation

Assuming you have followed the [Getting Started](https://kartverket.atlassian.net/wiki/spaces/SKIPDOK/pages/554827836/Komme+i+gang+med+Argo+CD)
guide, you can use ArgoKit in your apps-repo. The first step is to include the
ArgoKit library by running the following command:

```bash
$ git submodule add https://github.com/kartverket/argokit.git
```

Alternatively you can use jsonnet-bundler if prefer package managers over
submodules. To do this, install the CLI by following the instructions in the
[jsonnet-bundler](https://github.com/jsonnet-bundler/jsonnet-bundler) repo and
run the following command:

```bash
$ jb install https://github.com/kartverket/argokit@main
```

### Automatic version updates

It is highly recommended to use dependabot to automatically update the ArgoKit
version when a new version is released. To do this, add the following to your
`.github/dependabot.yml` file:

```yaml
version: 2
updates:
  - package-ecosystem: git-submodules
    directory: /
    schedule:
      interval: daily
```

With this configuration, dependabot will automatically create a PR to update the
ArgoKit version once a day provided that a new version has been released.

## Usage with jsonnet

If you use jsonnet in your apps-repo, you can use the ArgoKit library to deploy
ArgoCD applications by including the `argokit.libsonnet` file in your jsonnet
file and calling the `argokit.Application` function. For example, to deploy an
application, you can use the following jsonnet file:

```jsonnet
local argokit = import 'argokit/jsonnet/argokit.libsonnet';

local Probe = {
    path: "/healthz",
    port: 8080,
    failureThreshold: 3,
    timeout: 1,
    initialDelay: 0,
};

local BaseApp = {
    spec: {
        port: 8080,
        replicas: {
            min: 2,
            max: 5,
            targetCPUUtilization: 80,
        },
        liveness: Probe,
        readiness: Probe,
    },
};

[
    BaseApp + argokit.Application("foo-backend") {
        spec+: {
            image: "hello-world",
            ingresses: ["foo.bar.com"],
            accessPolicy: {
                inbound: {
                    rules: [{
                        application: "foo-frontend",
                    }],
                },
            },
        },
    },
]
```

### jsonnet API

The following templates are available for use in the `argokit.libsonnet` file:

| Template                   | Description                                                    | Example                                                                                  |
| -------------------------- | -------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `argokit.Application`      | Creates a Skiperator application                               | See above                                                                                |
| `argokit.GSMSecretStore`   | Creates a Google Secret Manager External Secrets `SecretStore` | [examples/jsonnet/secretstore-gsm.jsonnet](examples/jsonnet/secretstore-gsm.jsonnet)     |
| `argokit.GSMSecret`        | Creates a Google Secret Manager External Secrets `Secret`      | [examples/jsonnet/secretstore-gsm.jsonnet](examples/jsonnet/secretstore-gsm.jsonnet)     |
| `argokit.Roles`            | Creates a set of RBAC roles for this namespace                 | [examples/jsonnet/roles.jsonnet](examples/jsonnet/roles.jsonnet)                         |


## Contributing

Contributions are welcome! Please open an issue or PR if you would like to
see something changed or added.

## License

ArgoKit is licensed under the MIT License. See [LICENSE](LICENSE) for the full
license text.
