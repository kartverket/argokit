local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;

local stripLabels(o) = std.prune(o { metadata+: { labels: null } });

local stickySessionApp =
  application.new('aal-register', 'aal:1.0', 8080)
  + application.withStickySession('AAL-SESSION', null, '1800s');

local portLevelTlsApp =
  application.new('secure-app', 'secure:2.0', 9000)
  + application.withPortLevelTls('secure-pod.secure-svc', 80, 'ISTIO_MUTUAL', 'custom-dr-name');

local trafficTlsSniApp =
  application.new('my-app', 'app:1.0', 8080)
  + application.withTrafficPolicyTls('jenkins-matrikkel-no', 'jenkins.matrikkel.no', 'SIMPLE', 'jenkins.matrikkel.no');

local trafficTlsApp =
  application.new('my-app', 'app:1.0', 8080)
  + application.withTrafficPolicyTls('external-service', 'external.example.com');

test.new(std.thisFile)
+ test.case.new(
  name='application with sticky session',
  test=test.expect.eqDiff(
    actual=std.map(stripLabels, stickySessionApp.items),
    expected=std.map(
      stripLabels,
      [
        {
          apiVersion: 'skiperator.kartverket.no/v1alpha1',
          kind: 'Application',
          metadata: {
            name: 'aal-register',
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
  ),
)
+ test.case.new(
  name='application with custom port-level TLS configuration',
  test=test.expect.eqDiff(
    actual=std.map(stripLabels, portLevelTlsApp.items),
    expected=std.map(
      stripLabels,
      [
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
          },
          spec: {
            image: 'secure:2.0',
            port: 9000,
          },
        },
      ],
    ),
  ),
)
+ test.case.new(
  name='application with traffic policy TLS and SNI',
  test=test.expect.eqDiff(
    actual=std.map(stripLabels, trafficTlsSniApp.items),
    expected=std.map(
      stripLabels,
      [
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
          },
          spec: {
            image: 'app:1.0',
            port: 8080,
          },
        },
      ],
    ),
  ),
)
+ test.case.new(
  name='application with traffic policy TLS without SNI',
  test=test.expect.eqDiff(
    actual=std.map(stripLabels, trafficTlsApp.items),
    expected=std.map(
      stripLabels,
      [
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
          },
          spec: {
            image: 'app:1.0',
            port: 8080,
          },
        },
      ],
    ),
  ),
)
