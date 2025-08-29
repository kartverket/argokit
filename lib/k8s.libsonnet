// Inneholder funksjoner som oppretter ulike k8s-ressurser.
{
  local hashed = {
    local this = self,
    metadata+: {
      local hash = std.substr(std.md5(std.toString(this.data)), 0, 7),
      local orig_name = super.name,
      name: orig_name + '-' + hash,
      labels+: { name: orig_name },
    },
  },

  local hashedSecret = {
    local this = self,
    spec+: {
      target+: {
        local hash = std.substr(std.md5(std.toString(this.data)), 0, 7),
        local orig_name = super.name,
        name: orig_name + '-' + hash,
      },
    },
  },

  SecretList(map, base64Decoded=false):: [
    if std.type(map[x]) == 'object'
    then {
      remoteRef: {
        [if base64Decoded then 'decodingStrategy']: 'Base64',
        key: map[x],
        metadataPolicy: 'None',
      },
      secretKey: x,
    } else {
      // Let `null` value stay as such (vs string-ified)
      remoteRef: {
        [if base64Decoded then 'decodingStrategy']: 'Base64',
        key: if map[x] == null then null else std.toString(map[x]),
        metadataPolicy: 'None',
      },
      secretKey: x,
    }
    for x in std.objectFields(map)
  ],

  JSONSecretList(data):: [
    {
      remoteRef: {
        key: x.secretName,
        metadataPolicy: 'None',
        property: x.secretProperty,
        [if x.base64Decoded then 'decodingStrategy']: 'Base64',
      },
      secretKey: x.kubernetesSecretKey,
    }
    for x in data
  ],

  HashedConfigMap(name, data):: self.ConfigMap(name, data) + hashed,
  HashedExternalSecret(name, data):: self.ExternalSecret(name, data) + hashedSecret,

  ConfigMap(name, data):: {
    apiVersion: 'v1',
    kind: 'ConfigMap',
    metadata: {
      name: name + '-configmap',
    },
    data: data,
  },

  ExternalSecret(name, data, base64Decoded=false):: {
    local secret = self,

    apiVersion: 'external-secrets.io/v1',
    kind: 'ExternalSecret',
    metadata: {
      name: name + '-externalsecret',
    },
    data:: data,
    spec: {
      refreshInterval: '1h',
      secretStoreRef: {
        kind: 'SecretStore',
        name: 'gsm',
      },
      target: {
        name: name,
      },
      data: $.SecretList(secret.data, base64Decoded),
    },
  },

  ExternalSecretFromJSON(name, data):: {
    local secret = self,

    apiVersion: 'external-secrets.io/v1',
    kind: 'ExternalSecret',
    metadata: {
      name: name + '-externalsecret',
    },
    data:: data,
    spec: {
      refreshInterval: '1h',
      secretStoreRef: {
        kind: 'SecretStore',
        name: 'gsm',
      },
      target: {
        name: name,
      },
      data: $.JSONSecretList(secret.data),
    },
  },

  MaskinportenClient(name, consumedScopes)::
    local fullName = std.format('%s-maskinporten-client', name);
    {
      apiVersion: 'nais.io/v1',
      kind: 'MaskinportenClient',
      metadata: {
        name: fullName,
      },
      spec: {
        secretName: fullName,
        scopes: {
          consumes: std.map(function(x) { name: x }, consumedScopes),
        },
      },
    },

  Routing(name, hostname, routeMap)::
    {
      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'Routing',
      metadata: {
        name: name,
      },
      spec: {
        hostname: hostname,
        routes:
          [
            {
              pathPrefix: routeMap[x],
              targetApp: x,
              rewriteUri: false,
            }
            for x in std.objectFields(routeMap)
          ],
      },
    },
}
