local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;

test.new(std.thisFile)
+ test.case.new(
  name='application with sticky session using defaults',
  test=test.expect.eqDiff(
    actual=(application.new('test-app', 'test:1.0', 8080) + application.withStickySession()).items,
    expected=[
      {
        apiVersion: 'networking.istio.io/v1',
        kind: 'DestinationRule',
        metadata: {
          name: 'istio-sticky-test-app',
        },
        spec: {
          host: 'test-app',
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
      {
        apiVersion: 'skiperator.kartverket.no/v1alpha1',
        kind: 'Application',
        metadata: {
          name: 'test-app',
          labels: {
            'skip.kartverket.no/argokit-flavor': 'v2',
            'skip.kartverket.no/argokit-git-ref': '7dc5c1e46a97fe6e0cb11555d435d9c1f75ecc96',
            'skip.kartverket.no/argokit-tag': 'dev-315',
          },
        },
        spec: {
          image: 'test:1.0',
          port: 8080,
        },
      },
    ],
  ),
)
+ test.case.new(
  name='application with custom sticky session parameters',
  test=test.expect.eqDiff(
    actual=(application.new('test-app', 'test:1.0', 8080) + application.withStickySession(cookieName='MY-SESSION', cookiePath='/api', cookieTtl='3600s')).items,
    expected=[
      {
        apiVersion: 'networking.istio.io/v1',
        kind: 'DestinationRule',
        metadata: {
          name: 'istio-sticky-test-app',
        },
        spec: {
          host: 'test-app',
          trafficPolicy: {
            loadBalancer: {
              consistentHash: {
                httpCookie: {
                  name: 'MY-SESSION',
                  path: '/api',
                  ttl: '3600s',
                },
              },
            },
          },
        },
      },
      {
        apiVersion: 'skiperator.kartverket.no/v1alpha1',
        kind: 'Application',
        metadata: {
          name: 'test-app',
          labels: {
            'skip.kartverket.no/argokit-flavor': 'v2',
            'skip.kartverket.no/argokit-git-ref': '7dc5c1e46a97fe6e0cb11555d435d9c1f75ecc96',
            'skip.kartverket.no/argokit-tag': 'dev-315',
          },
        },
        spec: {
          image: 'test:1.0',
          port: 8080,
        },
      },
    ],
  ),
)
