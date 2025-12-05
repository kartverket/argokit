local utils = import '../../internal/utils.libsonnet';
local v = import '../../internal/validation.libsonnet';

{
  store: {
    new(name='gsm', gcpProject):
      v.string(gcpProject, 'gcpProject') +
      v.string(name, 'name') +
      {
        apiVersion: 'external-secrets.io/v1',
        kind: 'SecretStore',
        metadata: {
          name: name,
        },
        spec: {
          provider: {
            gcpsm: {
              projectID: gcpProject,
            },
          },
        },
      } + utils.withArgokitVersionLabel(),
  },
  secret: {
    new(name, secrets=[], allKeysFrom=[], secretStoreRef='gsm')::
      v.string(name, 'name') +
      v.array(secrets, 'secrets', allowEmpty=true) +
      v.array(allKeysFrom, 'allKeysFrom', allowEmpty=true) +
      v.string(secretStoreRef, 'secretStoreRef', allowEmpty=true) +
      (if std.length(secrets) > 0 || std.length(allKeysFrom) > 0 then {}
       else error 'invalid secret: either secrets or allKeysFrom must contain at least one item') +

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
          refreshInterval: '1h0m0s',
          secretStoreRef: {
            kind: 'SecretStore',
            name: secretStoreRef,
          },
          target: {
            name: name,
          },
        },
      } + utils.withArgokitVersionLabel(),
  },
}
