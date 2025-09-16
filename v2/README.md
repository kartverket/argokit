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
guide, you can use ArgoKit in your apps-repo. 

First you need to install jsonnet bundler. This is done by running `brew install jsonnet-bundler`.
Next run `jb init`, and finally run `jb install github.com/kartverket/argokit@main`. If you want 
to stay on a specific version use `jb install github.com/kartverket/argokit@2.0.0`

Remember to add `vendor/` to .gitignore

### Git submodules 
Alternatively you can use submodules if you prefer it over package managers.
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
  - package-ecosystem: git-submodules or jsonnet-bundler
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


TODO: Rewrite this section
| Template                    | Description                                                           | Example                                                                                    |
|-----------------------------|-----------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| `argokit.application.new()` | Creates a Skiperator application                                      | See above                                                                                  |
| `argokit.GSMSecretStore`    | Creates a Google Secret Manager External Secrets `SecretStore`        | [examples/jsonnet/secretstore-gsm.jsonnet](examples/jsonnet/secretstore-gsm.jsonnet)       |
| `argokit.GSMSecret`         | Creates a Google Secret Manager External Secrets `Secret`             | [examples/jsonnet/secretstore-gsm.jsonnet](examples/jsonnet/secretstore-gsm.jsonnet)       |
| `argokit.Roles`             | Creates a set of RBAC roles for this namespace                        | [examples/jsonnet/roles.jsonnet](examples/jsonnet/roles.jsonnet)                           |
| `argokit.AccessPolicies`    | Configures inbound and outbound access policies for services and jobs | [examples/jsonnet/accessPolicies.jsonnet](examples/jsonnet/accessPolicies.jsonnet)         |
| `argokit.replicas`          | Configures replicasfor the application                           | |

### argoKit's Replicas API
**NOTE!** It is not recommended to run with less than 2 replicas... 
| Template                                | Description                                                     | Example                                                                                    |
|-----------------------------------------|-----------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| `argokit.application.withReplicas`   | Create replicas for an application with sensible defaults  | [examples/jsonnet/replicasets.jsonnet](v2/examples/replicasets.jsonnet)               |
| `argokit.application.withReplicas`   | Create replicas for an application with memory monitoring  | [examples/jsonnet/replicasets-with-memory.jsonnet](v2/examples/replicasets-with-memory.jsonnet)   |
| `argokit.application.withReplicas`   | Creates a static replica without cpu- and memory monitoring | [examples/jsonnet/replicasets-static.jsonnet](v2/examples/replicasets-static.jsonnet) |


### argoKit's Environment API

| Template                                              | Description                                                    | Example                                                                  |
|-------------------------------------------------------|----------------------------------------------------------------|--------------------------------------------------------------------------|
| `argokit.[application\|skipJOB].withVariable`         | Creates environment variables for an app                       | [examples/jsonnet/envVariables.jsonnet](examples/jsonnet/envVariables.jsonnet) |
| `argokit.[application\|skipJOB].withVariableSecret`   | Creates environment variable from a secret                     | [examples/jsonnet/envVariables.jsonnet](examples/jsonnet/envVariables.jsonnet) |
| `argokit.[application\|skipJOB].withVariableSecret`   | Creates environment variable from a secret for a Job container | [examples/jsonnet/envVariables.jsonnet](examples/jsonnet/envVariables.jsonnet) |

---
The following templates are available for use in the `dbArchive.libsonnet` file:

| Template                 | Description                                                   | Example                                                                  |
|--------------------------|---------------------------------------------------------------|--------------------------------------------------------------------------|
| `dbArchive.dbArchiveJob` | Creates a SKIPJob that creates a sql dump and stores it in S3 | [examples/jsonnet/dbArchive.jsonnet](examples/jsonnet/dbArchive.jsonnet) |

### Input parameters 

#### dbArchiveJob

| Parameter                            | Type    | Default Value            | Description                                                                                                                       |
|:-------------------------------------|:--------|:-------------------------|:----------------------------------------------------------------------------------------------------------------------------------|
| **`instanceName`**                   | String  | -                        | **Required.** A unique name for the job and related resources. This name is used as a base for `SKIPJob` and secrets.             |
| **`schedule`**                       | String  | -                        | **Required.** A cron string defining when the job should run (e.g., `"0 2 * * *"` to run at 02:00 every night).                   |
| **`databaseIP`**                     | String  | -                        | **Required.** The IP address of the PostgreSQL database to be archived.                                                           |
| **`gcpS3CredentialsSecret`**         | String  | -                        | **Required.** Name of the secret in GSM containing S3 credentials (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`).              |
| **`databaseName`**                   | String  | -                        | **Required.** Name of the database to be archived.                                                                                |
| **`archiveUser`**                    | String  | `'postgres'`             | The database user the job should use to connect.                                                                                  |
| **`serviceAccount`**                 | String  | `'dummyaccount@gcp.iam'` | GCP Service Account used by the Kubernetes job to authenticate against Google Cloud (e.g., to fetch secrets from GSM).            |
| **`cloudsqlInstanceConnectionName`** | String  | -                        | **Required.** The connection name of the Cloud SQL instance (format: `project:region:instance`). Needed for Cloud SQL Auth Proxy. |
| **`port`**                           | Integer | `5432`                   | The port number of the PostgreSQL database.                                                                                       |
| **`S3Host`**                         | String  | `'s3-rin.statkart.no'`   | The hostname of the S3 endpoint where the archive should be stored.                                                               |
| **`S3DestinationPath`**              | String  | -                        | **Required.** Full S3 path where the database archive should be placed (e.g., `s3://my-bucket/archive/database/`).                |
| **`fullDump`**                       | Bool    | false                    | Flag to include database roles `without passwords` in the dump.                                                                   |

## Contributing

Contributions are welcome! Please open an issue or PR if you would like to
see something changed or added.

## License

ArgoKit is licensed under the MIT License. See [LICENSE](LICENSE) for the full
license text.
