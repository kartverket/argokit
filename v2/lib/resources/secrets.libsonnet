local v = import '../../internal/validation.libsonnet';
{
  store: {
    new(gcpProject):
      v.string(gcpProject, 'gcpProject') +
      {
        apiVersion: 'external-secrets.io/v1',
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
  },
  secret: {
    new(name, secrets=[], allKeysFrom=[])::
      v.string(name, 'name') +
      v.array(secrets, 'secrets', allowEmpty=true) +
      v.array(allKeysFrom, 'allKeysFrom', allowEmpty=true) +

      {
        apiVersion: 'external-secrets.io/v1',
        kind: 'ExternalSecret',
        metadata: {
          name: name,
        },
        spec: {
          [if std.length(secrets) > 0 then 'data']: [{
            secretKey: secret.toKey,
            remoteRef: {
              key: secret.fromSecret,
              metadataPolicy: 'None',
            },
          } for secret in secrets],
          [if std.length(allKeysFrom) > 0 then 'dataFrom']: [{
            extract: {
              key: secret.fromSecret,
              metadataPolicy: 'None',
            },
          } for secret in allKeysFrom],
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
  },
}
