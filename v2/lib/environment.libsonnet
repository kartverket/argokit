{
  /**
  Creates an environment variable with a static value.
  Parameters:
    - name: string - The name of the environment variable.
    - value: string - The value to assign to the environment variable.
  */
  withVariable(name, value):: {
    spec+: {
      env+: [
        {
          name: name,
          value: value,
        },
      ],
    },
  },

  withSecret(secretName):: {
    local variableSecret(secretName) = {
      envFrom+: [
        { secret: secretName },
      ],
    },
    spec+: variableSecret(secretName),
  },

  /**
  Creates an environment variable for a job or application whose value is sourced from a secret.
  Parameters:
    - name: string - The name of the environment variable.
    - secretRef: string - The name of the secret resource. The key used in the secret is the same as the environment variable name.
    - key string (optional) - The key in the secret to use for the value. Defaults to the name of the environment variable.
  */
  withVariableSecret(name, secretRef, key=name):: {
    local variableSecret(name, secretRef, key) = {
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
    spec+: variableSecret(name, secretRef, key),
  },
}
