{
  /**
  Creates an environment variable with a static value.
  Parameters:
    - name: string - The name of the environment variable.
    - value: string - The value to assign to the environment variable.
  */
  variable(name, value): {
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
    - key string (optional) - The key in the secret to use for the value. Defaults to the name of the environment variable.  
  */
  variableSecret(name, secretRef, key=name): {
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
  /**
  Creates an environment variable for a job container, sourced from a secret.
  Parameters:
    - name: string - The name of the environment variable.
    - secretRef: string - The name of the secret resource. The key used in the secret is the same as the environment variable name.
  */
  variableSecretJob(name, secretRef): {
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
}