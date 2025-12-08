local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;
local utils = import '../internal/utils.libsonnet';

application.new('app', 'foo.io/image', 8080)

+ application.withObjects(
  {
    apiVersion: 'networking.istio.io/v1alpha3',
    kind: 'DestinationRule',
    metadata: {
      name: 'istio-sticky' + 'test',
    },
    spec: {
      host: 'test',
      trafficPolicy: {
        loadBalancer: {
          consistentHash: {
            httpCookie: {
              name: 'ISTIO-STICKY',
              path: '/',
              ttl: '0',
            },
          },
        },
      },
    },
  } + utils.withArgokitVersionLabel(false, 'v2'),
)
