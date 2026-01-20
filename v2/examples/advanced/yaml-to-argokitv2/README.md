# From YAML to ArgoKit v2

This folder provides side-by-side comparisons demonstrating how to migrate standard Kubernetes/Skiperator YAML manifests into ArgoKit v2 Jsonnet.

## Examples Included

### 1. Access Policies (`accessPolicy/`)
Demonstrates how to define access policies (not to be confused with the Kubernetes native `NetworkPolicy`) between applications.
*   **YAML**: Manual definition of `accessPolicy` in application manifests.
*   **ArgoKit**: Using `withInboundSkipApp` and `withOutboundSkipApp` wrappers to succinctly define allow-lists.

### 2. External Secrets & Stores (`externalSecretsAndStores/`)
Demonstrates managing secrets from external providers (like Google Secret Manager).
*   **YAML**: Raw `SecretStore` and `ExternalSecret` resources.
*   **ArgoKit**: Using `externalSecrets.store` and `withEnvironmentVariablesFromExternalSecret` to automatically inject secrets into your application.
*   **Best Practice**: Shows how to modularize shared resources (like a Secret Store) into a `common.jsonnet` file to be reused across multiple apps.
