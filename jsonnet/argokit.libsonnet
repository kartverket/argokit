{
  Roles: {
    local this = self,
    members:: error 'members required',

    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'RoleBinding',
    metadata: {
      name: 'team-admin',
      annotations: {
        description: 'Binds cluster-admin to every member and relevant SAs within a product. Allows all subjects to have full rights within their namespace. Usually reserved for dev/sandbox.',
      },
    },
    subjects: [
      {
        apiGroup: 'rbac.authorization.k8s.io',
        kind: 'User',
        name: user,
      }
      for user in this.members
    ],
    roleRef: {
      kind: 'ClusterRole',
      name: 'cluster-admin',
      apiGroup: 'rbac.authorization.k8s.io',
    },
  },
  VaultSecretStore(teamname, serviceAccount, env): {
    apiVersion: 'external-secrets.io/v1beta1',
    kind: 'SecretStore',
    metadata: {
      name: 'vault',
    },
    spec: {
      provider: {
        vault: {
          auth: {
            kubernetes: {
              mountPath: 'atkv1-%s' % env,
              role: teamname,
              serviceAccountRef: {
                name: serviceAccount,
              },
            },
          },
        },
      },
      caBundle: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURoakNDQW02Z0F3SUJBZ0lRSHhRNCszNDQ1TFJDazN6ZlVUUENPekFOQmdrcWhraUc5dzBCQVFzRkFEQkwKTVJJd0VBWUtDWkltaVpQeUxHUUJHUllDYm04eEdEQVdCZ29Ka2lhSmsvSXNaQUVaRmdoemRHRjBhMkZ5ZERFYgpNQmtHQTFVRUF4TVNTMkZ5ZEhabGNtdGxkQ0JTYjI5MElFTkJNQjRYRFRFMk1ETXlNakUwTURJek0xb1hEVFEyCk1ETXlNakUwTVRJek0xb3dTekVTTUJBR0NnbVNKb21UOGl4a0FSa1dBbTV2TVJnd0ZnWUtDWkltaVpQeUxHUUIKR1JZSWMzUmhkR3RoY25ReEd6QVpCZ05WQkFNVEVrdGhjblIyWlhKclpYUWdVbTl2ZENCRFFUQ0NBU0l3RFFZSgpLb1pJaHZjTkFRRUJCUUFEZ2dFUEFEQ0NBUW9DZ2dFQkFKSjBaMWExNEpYblkxSUptaDgweGgwSFhKZmZZZ2lXCjVFRGtxOUVFUXRPYk1SUlVDbm16aUlDQ3lPM3hLQUdqWEJ1aFowL21vVUJnUXFwbWtDSlIvQ1pubnNJMVZ6QVkKMHNPbWlRaFVNSVdCUzhDRkltVWNoTmJOREM1SzZYVStwNGZodWxFN0lPL3FTZDd3V2dNSFZLdUE5eVBvVFJsMwowaVpZdG5IcUlCb3dZS3dJVHBBSmpwME5hTmNIalY2TWVOdlBrR1RURk45S1MxcG53QjhZVnFVYUZXdDJGVDh1CjBSTE9kUUgyeFFva1l4YW1RRWNqaEFBSnlzVDdkK25YemRzYUEwYXQrYlNwUExxTURVOW5JZFpuRGc1TlgyY0oKcnNlRm5tWTJ3Q2NLL2tMUUpVSWxSQVQ0UHI5Y08rZDRvSytRTFFOaGZpVmxUa0RaZU1ISHhia0NBd0VBQWFObQpNR1F3RXdZSkt3WUJCQUdDTnhRQ0JBWWVCQUJEQUVFd0N3WURWUjBQQkFRREFnR0dNQThHQTFVZEV3RUIvd1FGCk1BTUJBZjh3SFFZRFZSME9CQllFRk5xNUhyME9mV3kzbWMvckxXUEZrMHpmSWhlck1CQUdDU3NHQVFRQmdqY1YKQVFRREFnRUFNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUJkdHFVbDdvWFFTYWxIWjh6Y2dRZllvZWVxTGNwRQp5RjhFUngwdnFQc0hmY2VnL0ZXZEhFUVh4TWtPN1JER1Fzb2NmTVZvR0FBT1R3VlFPTHZCNmg4MnhCRVozSjBqCjBGMWkvcSs0WEd2NjdvOW43Z2NLNUFGOVNhcy9MVFB4N3dqQjV2dS85TkxyRkE1eXgyUG1iRnpNNFZRcXkwZnQKd2loaTdxMlhoQlVYUGo0SEdhTVE2aE1CYkRhSVl0Z0ovWWlkTFpSeGZWQVpGVEN4UDlPcDZVR3d0Zi9DeHdPSQo5ZkxtaWIwUDZCWG9sR3h1eU5XdHU2K0Vxc1JtMGtvcE5jcDkyZWpiOGsyb3R4VWdRcGNoVzRwd2RLMWZ3azhECndVblY5emhTc2k5eVZGMVVRUDZRcEJCeFNDZE5PT3JSSEg0N1djZmF0VUg0SWhuQW9PS0VyUVpBCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K',
      path: teamname,
      server: 'https://vault.vault:8200',
    },
  },
  GSMSecretStore(gcpProject): {
    apiVersion: 'external-secrets.io/v1beta1',
    kind: 'SecretStore',
    metadata: {
      name: 'gsm',
    },
    spec: {
      provider: {
        gcpsm: {
          projectID: gcpProject,
        },
      },
    },
  },
  VaultSecret(name): {
    local input = self,
    secrets:: null,
    allKeysFrom:: null,

    apiVersion: 'external-secrets.io/v1beta1',
    kind: 'ExternalSecret',
    metadata: {
      name: name,
    },
    spec: {
      [if input.secrets != null then 'data']: [{
        secretKey: secret.toKey,
        remoteRef: {
          key: secret.fromSecret,
          property: secret.fromProperty,
        },
      } for secret in input.secrets],
      [if input.allKeysFrom != null then 'dataFrom']: [{
        extract: {
          key: secret.fromSecret,
          property: secret.fromProperty,
        },
      } for secret in input.allKeysFrom],
      refreshInterval: '1h',
      secretStoreRef: {
        kind: 'SecretStore',
        name: 'vault',
      },
      target: {
        name: name,
      },
    },
  },
  GSMSecret(name): {
    local input = self,
    secrets:: null,
    allKeysFrom:: null,

    apiVersion: 'external-secrets.io/v1beta1',
    kind: 'ExternalSecret',
    metadata: {
      name: name,
    },
    spec: {
      [if input.secrets != null then 'data']: [{
        secretKey: secret.toKey,
        remoteRef: {
          key: secret.fromSecret,
        },
      } for secret in input.secrets],
      [if input.allKeysFrom != null then 'dataFrom']: [{
        extract: {
          key: secret.fromSecret,
        },
      } for secret in input.allKeysFrom],
      refreshInterval: '1h',
      secretStoreRef: {
        kind: 'SecretStore',
        name: 'gsm',
      },
      target: {
        name: name,
      },
    },
  },
  Application(name): {
    apiVersion: 'skiperator.kartverket.no/v1alpha1',
    kind: 'Application',
    metadata: {
      name: name,
    },
  },
}
