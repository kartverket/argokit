local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;

test.new(std.thisFile)
+ test.case.new(
  name='application with sticky session using defaults (no path)',
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
            'skip.kartverket.no/argokit-git-ref': 'a838ee16fbc34ba7efba0be7c0d5a16fe7e7945c',
            'skip.kartverket.no/argokit-tag': 'dev-327',
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
  name='application with custom sticky session parameters including path',
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
            'skip.kartverket.no/argokit-git-ref': 'a838ee16fbc34ba7efba0be7c0d5a16fe7e7945c',
            'skip.kartverket.no/argokit-tag': 'dev-327',
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
  name='application with custom cookie name and ttl without path',
  test=test.expect.eqDiff(
    actual=(application.new('aal-register', 'aal:1.0', 8080) + application.withStickySession(cookieName='AAL-SESSION', cookieTtl='1800s')).items,
    expected=[
      {
        apiVersion: 'skiperator.kartverket.no/v1alpha1',
        kind: 'Application',
        metadata: {
          name: 'aal-register',
          labels: {
            'skip.kartverket.no/argokit-flavor': 'v2',
            'skip.kartverket.no/argokit-git-ref': 'a838ee16fbc34ba7efba0be7c0d5a16fe7e7945c',
            'skip.kartverket.no/argokit-tag': 'dev-327',
          },
        },
        spec: {
          image: 'aal:1.0',
          port: 8080,
        },
      },
      {
        apiVersion: 'networking.istio.io/v1',
        kind: 'DestinationRule',
        metadata: {
          name: 'istio-sticky-aal-register',
        },
        spec: {
          host: 'aal-register',
          trafficPolicy: {
            loadBalancer: {
              consistentHash: {
                httpCookie: {
                  name: 'AAL-SESSION',
                  ttl: '1800s',
                },
              },
            },
          },
        },
      },
    ],
  ),
)
