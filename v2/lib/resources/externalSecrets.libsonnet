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
      }
  } + utils.withArgokitVersionLabel(flavor='v2'),
  secret: {
    new(name, creationPolicy=null, secrets=[], allKeysFrom=[], secretStoreRef='gsm')::
      v.string(name, 'name') +
      (if creationPolicy != null then v.string(creationPolicy, 'creationPolicy') else {}) +
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
            remoteRef: std.prune({
              conversionStrategy: std.get(secret, 'conversionStrategy', 'Default'),
              decodingStrategy: std.get(secret, 'decodingStrategy', 'None'),
              key: secret.fromSecret,
              metadataPolicy: std.get(secret, 'metadataPolicy', 'None'),
              property: std.get(secret, 'property', null),
            }),
          } for secret in secrets],
          [if std.length(allKeysFrom) > 0 then 'dataFrom']: [{
            extract: std.prune({
              conversionStrategy: std.get(secret, 'conversionStrategy', 'Default'),
              decodingStrategy: std.get(secret, 'decodingStrategy', 'None'),
              key: secret.fromSecret,
              metadataPolicy: std.get(secret, 'metadataPolicy', 'None'),
              property: std.get(secret, 'property', null),
            }),
          } for secret in allKeysFrom],
          refreshInterval: '1h0m0s',
          secretStoreRef: {
            kind: 'SecretStore',
            name: secretStoreRef,
          },
          target: std.prune({
            name: name,
            creationPolicy: creationPolicy,
          }),
        },
      } + utils.withArgokitVersionLabel(flavor='v2'),
  } 
}