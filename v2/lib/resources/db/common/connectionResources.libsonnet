local tlsRoute(p, env, name, hostname, serviceName) = {
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'TLSRoute',
  metadata: {
    name: name,
  },
  spec: {
    parentRefs: [
      {
        group: 'gateway.networking.k8s.io',
        kind: 'Gateway',
        name: env.gatewayName,
        namespace: p.gatewayNS,
        sectionName: env.gatewaySectionName,
      },
    ],
    hostnames: [hostname],
    rules: [
      {
        backendRefs: [
          {
            group: '',
            kind: 'Service',
            name: serviceName,
            port: 5432,
            weight: 1,
          },
        ],
      },
    ],
  },
};

local headlessServices(p, clusterName) = {
  ['%s-%d-hs' % [clusterName, instanceNumber]]: {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: '%s-%d-hs' % [clusterName, instanceNumber],
    },
    spec: {
      selector: {
        'cnpg.io/instanceName': '%s-%d' % [clusterName, instanceNumber],
      },
      clusterIP: 'None',
      ports: [
        {
          name: 'status',
          port: 8000,
          targetPort: 8000,
        },
        {
          name: 'postgres',
          port: 5432,
          targetPort: 5432,
        },
      ],
    },
  }
  for instanceNumber in std.range(1, p.instances)
};

local new(p, clusterName, env, certSecretName) =
  local writeHost =
    '%s-write.%s.kartverket-intern.cloud' % [p.databaseName, env.prettyUrl];
  local readHost =
    '%s-read.%s.kartverket-intern.cloud' % [p.databaseName, env.prettyUrl];
  {
    certificate: {
      apiVersion: 'cert-manager.io/v1',
      kind: 'Certificate',
      metadata: {
        name: clusterName,
      },
      spec: {
        secretName: certSecretName,
        issuerRef: {
          group: 'cert-manager.io',
          kind: 'ClusterIssuer',
          name: p.tlsIssuerName,
        },
        dnsNames: [writeHost, readHost],
        privateKey: {
          rotationPolicy: 'Always',
        },
      },
    },
    tlsRouteWrite:
      tlsRoute(p, env, clusterName + '-write', writeHost, clusterName + '-rw'),
    tlsRouteRead:
      tlsRoute(p, env, clusterName + '-read', readHost, clusterName + '-ro'),
  } + headlessServices(p, clusterName);

{
  headlessServices: headlessServices,
  new: new,
}
