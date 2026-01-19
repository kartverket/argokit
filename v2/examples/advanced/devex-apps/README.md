# Devex Apps Example - Multi-Environment Pattern

This folder illustrates an advanced pattern for managing application configurations across multiple environments (e.g., `dev` vs `prod`) while keeping code DRY (Don't Repeat Yourself).

## Key Concepts

1.  **Reusable Application Templates (`applications/`)**:
    Instead of defining a static application manifest, applications are defined as **functions** (in `.libsonnet` files). These functions accept parameters like `env` and `version` to customize the output dynamically.

    *Example (`applications/devex-frontend-new.libsonnet`):*
    ```jsonnet
    function(name, env, version)
      application.new(name, image=version, ...)
      + application.withEnvironmentVariables({
          // Logic based on the 'env' parameter
          CLIENT_ID: if env == 'prod' then 'prod-id' else 'dev-id'
      })
    ```

2.  **Environment Instantiation (`env/`)**:
    Specific environments contain simple `.jsonnet` files that import the reusable template and invoke the function with concrete values.

    *Example (`env/cluster1-dev/devex-frontend-new.jsonnet`):*
    ```jsonnet
    local app = import '../../applications/devex-frontend-new.libsonnet';
    app(name='frontend', env='dev', version='1.2.3')
    ```

This approach allows you to maintain a single source of truth for your application structure while easily handling configuration drift between environments.