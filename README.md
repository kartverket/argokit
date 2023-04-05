# ArgoKit

<p align="center">
<img src="logo.png" alt="ArgoKit Logo" width="300px" />
</p>

ArgoKit is a set of reusable manifests and jsonnet templates that makes it
easier to deploy ArgoCD applications on SKIP. It is a work in progress and will
be updated as we learn more about how to best deploy with ArgoCD on SKIP. If you
have any questions, please reach out to the #gen-argocd channel in Slack.

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

Note that installation may not be required if you use kustomize. See the section
on [Usage with kustomize](#usage-with-kustomize) for more information.

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
file and calling the `argokit.application` function. For example, to deploy an
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
| `argokit.VaultSecretStore` | Creates a Vault External Secrets `SecretStore`                 | [examples/jsonnet/secretstore-vault.jsonnet](examples/jsonnet/secretstore-vault.jsonnet) |
| `argokit.VaultSecret`      | Creates a Vault External Secrets `Secret`                      | [examples/jsonnet/secretstore-vault.jsonnet](examples/jsonnet/secretstore-vault.jsonnet) |
| `argokit.Roles`            | Creates a set of RBAC roles for this namespace                 | [examples/jsonnet/roles.jsonnet](examples/jsonnet/roles.jsonnet)                         |

## Usage with kustomize

If you use kustomize in your apps-repo, you can use the ArgoKit library to
deploy ArgoCD applications by including the `argokit` directory in your
kustomization file. For example, to deploy an application, you can use the
following kustomization file:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- https://github.com/kartverket/argokit.git/manifests/application.yaml?ref=v0.1.0

patches:
- path: patches/application.yaml

images:
- name: hello-world
  newTag: "1.2.3"
```

Note that Kustomize is pulling directly from ArgoKit's GitHub repo, so setting
up the submodule is not necessary for this approach.

Your patch file could look something like this, which would be merged into the
result:

```yaml
apiVersion: skiperator.kartverket.no/v1alpha1
kind: Application
metadata:
  name: foo-backend
spec:
  image: hello-world
  port: 8080
  ingresses:
  - foo.bar.com
  accessPolicy:
    inbound:
      rules:
      - application: foo-frontend
```

## Usage with plain kubernetes manifests

ArgoKit also includes a set of kubernetes manifests that can be used as a
starting point for deploying ArgoCD applications on SKIP. The manifests are
located in the `manifests` directory and can be used as is or as a starting
point for your own manifests.

If you choose to use the manifests with no other tooling it is probably best to
copy them over to your apps-repo and modify them there as they will require a
decent amount of modification. This way you can easily change the manifests to
include your own changes.

Some of the manifests are however usable with minor changes. For example, the
secretstores can easily be patched to meet most teams' needs. To do this, you
can use the following command to run a merge patch and output a new manifest:

```bash
$ kubectl patch --local --type=merge -f argokit/manifests/secretstore-gsm.yaml \
  -p '{"spec": {"provider": {"gcpSecretsManager": {"project": "my-project"}}}}' \
  -o yaml > my-gsm-secretstore.yaml
```

If more intricate patches are required a json patch may be more convenient.
Using this kind of patch a list of operations can be specified to modify the
manifest. See the [RFC 6902](https://www.rfc-editor.org/rfc/rfc6902) (JSON
Patch) documentation for more information on how to use this kind of patch.


```bash
$ kubectl patch --local --type=json -f argokit/manifests/secretstore-gsm.yaml -p '[
    {"op": "add", "path": "/spec/provider/gcpSecretsManager/project", "value": "my-project"}
  ]' \
  -o yaml > my-gsm-secretstore.yaml
```

## Contributing

Contributions are welcome! Please open an issue or PR if you would like to
see something changed or added.

## License

ArgoKit is licensed under the MIT License. See [LICENSE](LICENSE) for the full
license text.
