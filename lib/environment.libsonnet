{
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
