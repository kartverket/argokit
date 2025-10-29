{
  /**
  Creates an environment variable with a static value.
  Parameters:
    - name: string - The name of the environment variable.
    - value: string - The value to assign to the environment variable.
  */
  withEnvironmentVariable(name, value):: {
    application+: {
      spec+: {
        env+: [
          {
            name: name,
            value: value,
          },
        ],
      },
    },
  },

  /**
  Creates multiple environment variables with static values.
  Parameters:
    - pairs: map - Map of key-value pairs of env variables
  */
  withEnvironmentVariables(pairs):: {
    application+: {
      spec+: {
        env+: std.map(function(k) {
          name: k,
          value: pairs[k],
        }, std.objectFields(pairs)),
      },
    },
  },

  withEnvironmentVariablesFromSecret(secretName):: {
    local variableSecret(secretName) = {
      envFrom+: [
        { secret: secretName },
      ],
    },
    application+: {
      spec+: variableSecret(secretName),
    },
  },

  /**
  Creates an environment variable for a job or application whose value is sourced from a secret.
  Parameters:
    - name: string - The name of the environment variable.
    - secretRef: string - The name of the secret resource. The key used in the secret is the same as the environment variable name.
    - key string (optional) - The key in the secret to use for the value. Defaults to the name of the environment variable.
  */
  withEnvironmentVariableFromSecret(name, secretRef, key=name):: {
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
    application+: {
      spec+: variableSecret(name, secretRef, key),
    },
  },
}
