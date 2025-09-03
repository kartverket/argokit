{
  /**
  Creates an environment variable with a static value.
  Parameters:
    - name: string - The name of the environment variable.
    - value: string - The value to assign to the environment variable.
  */
  envVariable(name, value): {
    spec+: {
      env+: [
        {
          name: name,
          value: value,
        },
      ],
    },
  },
  /**
  Creates an environment variable whose value is sourced from a secret.
  Parameters:
    - name: string - The name of the environment variable.
    - secretRef: string - The name of the secret resource. The key used in the secret is the same as the environment variable name.
  */
  envVariableSecret(name, secretRef): {
    spec+: {
      env+: [
        {
          name: name,
          valueFrom: {
            secretKeyRef: {
              name: secretRef,
              key: name,
            },
          },
        },
      ],
    },
  },
  /**
  Creates an environment variable for a job container, sourced from a secret.
  Parameters:
    - name: string - The name of the environment variable.
    - secretRef: string - The name of the secret resource. The key used in the secret is the same as the environment variable name.
  */
  envVariableSecretJob(name, secretRef): {
    spec+: {
      container+: {
        env+: [
          {
            name: name,
            valueFrom: {
              secretKeyRef: {
                name: secretRef,
                key: name,
              },
            },
          },
        ],
      },
    },
  },
  /*
    Creates an environment variable from a secret using a custom key.
    Parameters:
      - name: string - The name of the environment variable.
      - key: string - The key in the Secret to use for the value.
      - secretRef: string - The name of the secret resource.
  */
  envVariableSecretCustomKey(name, key, secretRef): {
    spec+: {
      env+: [
        {
          name: name,
          valueFrom: {
            secretKeyRef: {
              name: secretRef,
              key: key,
            },
          },
        },
      ],
    },
  },
}