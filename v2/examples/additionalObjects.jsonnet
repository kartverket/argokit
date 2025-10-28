local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;


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
  },
)
