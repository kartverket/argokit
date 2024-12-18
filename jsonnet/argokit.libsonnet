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
          metadataPolicy: 'None',
        },
      } for secret in input.secrets],
      [if input.allKeysFrom != null then 'dataFrom']: [{
        extract: {
          key: secret.fromSecret,
          metadataPolicy: 'None',
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
