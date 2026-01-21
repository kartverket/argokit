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
        apiVersion: 'networking.istio.io/v1alpha3',
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
            'skip.kartverket.no/argokit-git-ref': 'edbabd565a7515ba8cd3909631396344c5a3a2ee',
            'skip.kartverket.no/argokit-tag': 'dev-dirty',
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
        apiVersion: 'networking.istio.io/v1alpha3',
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
            'skip.kartverket.no/argokit-git-ref': 'edbabd565a7515ba8cd3909631396344c5a3a2ee',
            'skip.kartverket.no/argokit-tag': 'dev-dirty',
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
            'skip.kartverket.no/argokit-git-ref': 'edbabd565a7515ba8cd3909631396344c5a3a2ee',
            'skip.kartverket.no/argokit-tag': 'dev-dirty',
          },
        },
        spec: {
          image: 'aal:1.0',
          port: 8080,
        },
      },
      {
        apiVersion: 'networking.istio.io/v1alpha3',
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
+ test.case.new(
  name='application with port-level TLS using defaults',
  test=test.expect.eqDiff(
    actual=(application.new('my-service', 'myapp:1.0', 8080) + application.withPortLevelTls('external.example.com')).items,
    expected=[
      {
        apiVersion: 'skiperator.kartverket.no/v1alpha1',
        kind: 'Application',
        metadata: {
          name: 'my-service',
          labels: {
            'skip.kartverket.no/argokit-flavor': 'v2',
            'skip.kartverket.no/argokit-git-ref': 'edbabd565a7515ba8cd3909631396344c5a3a2ee',
            'skip.kartverket.no/argokit-tag': 'dev-dirty',
          },
        },
        spec: {
          image: 'myapp:1.0',
          port: 8080,
        },
      },
      {
        apiVersion: 'networking.istio.io/v1',
        kind: 'DestinationRule',
        metadata: {
          name: 'my-service',
        },
        spec: {
          host: 'external.example.com',
          trafficPolicy: {
            portLevelSettings: [
              {
                port: {
                  number: 443,
                },
                tls: {
                  mode: 'SIMPLE',
                },
              },
            ],
          },
        },
      },
    ],
  ),
)
+ test.case.new(
  name='application with custom port-level TLS configuration',
  test=test.expect.eqDiff(
    actual=(application.new('secure-app', 'secure:2.0', 9000) + application.withPortLevelTls('secure-pod.secure-svc', 80, 'ISTIO_MUTUAL', 'custom-dr-name')).items,
    expected=[
      {
        apiVersion: 'networking.istio.io/v1',
        kind: 'DestinationRule',
        metadata: {
          name: 'custom-dr-name',
        },
        spec: {
          host: 'secure-pod.secure-svc',
          trafficPolicy: {
            portLevelSettings: [
              {
                port: {
                  number: 80,
                },
                tls: {
                  mode: 'ISTIO_MUTUAL',
                },
              },
            ],
          },
        },
      },
      {
        apiVersion: 'skiperator.kartverket.no/v1alpha1',
        kind: 'Application',
        metadata: {
          name: 'secure-app',
          labels: {
            'skip.kartverket.no/argokit-flavor': 'v2',
            'skip.kartverket.no/argokit-git-ref': 'edbabd565a7515ba8cd3909631396344c5a3a2ee',
            'skip.kartverket.no/argokit-tag': 'dev-dirty',
          },
        },
        spec: {
          image: 'secure:2.0',
          port: 9000,
        },
      },
    ],
  ),
)
+ test.case.new(
  name='application with traffic policy TLS and SNI',
  test=test.expect.eqDiff(
    actual=(application.new('my-app', 'app:1.0', 8080) + application.withTrafficPolicyTls('jenkins-matrikkel-no', 'jenkins.matrikkel.no', 'SIMPLE', 'jenkins.matrikkel.no')).items,
    expected=[
      {
        apiVersion: 'networking.istio.io/v1',
        kind: 'DestinationRule',
        metadata: {
          name: 'jenkins-matrikkel-no',
        },
        spec: {
          host: 'jenkins.matrikkel.no',
          trafficPolicy: {
            tls: {
              mode: 'SIMPLE',
              sni: 'jenkins.matrikkel.no',
            },
          },
        },
      },
      {
        apiVersion: 'skiperator.kartverket.no/v1alpha1',
        kind: 'Application',
        metadata: {
          name: 'my-app',
          labels: {
            'skip.kartverket.no/argokit-flavor': 'v2',
            'skip.kartverket.no/argokit-git-ref': 'edbabd565a7515ba8cd3909631396344c5a3a2ee',
            'skip.kartverket.no/argokit-tag': 'dev-dirty',
          },
        },
        spec: {
          image: 'app:1.0',
          port: 8080,
        },
      },
    ],
  ),
)
+ test.case.new(
  name='application with traffic policy TLS without SNI',
  test=test.expect.eqDiff(
    actual=(application.new('my-app', 'app:1.0', 8080) + application.withTrafficPolicyTls('external-service', 'external.example.com')).items,
    expected=[
      {
        apiVersion: 'networking.istio.io/v1',
        kind: 'DestinationRule',
        metadata: {
          name: 'external-service',
        },
        spec: {
          host: 'external.example.com',
          trafficPolicy: {
            tls: {
              mode: 'SIMPLE',
            },
          },
        },
      },
      {
        apiVersion: 'skiperator.kartverket.no/v1alpha1',
        kind: 'Application',
        metadata: {
          name: 'my-app',
          labels: {
            'skip.kartverket.no/argokit-flavor': 'v2',
            'skip.kartverket.no/argokit-git-ref': 'edbabd565a7515ba8cd3909631396344c5a3a2ee',
            'skip.kartverket.no/argokit-tag': 'dev-dirty',
          },
        },
        spec: {
          image: 'app:1.0',
          port: 8080,
        },
      },
    ],
  ),
)
