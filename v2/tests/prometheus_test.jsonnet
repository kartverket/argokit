local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;

test.new(std.thisFile)
+ test.case.new(
  name='prometheus basic configuration',
  test=test.expect.eqDiff(
    actual=(application.withPrometheus(path='/metrics', port=8080)).application.spec,
    expected={
      prometheus: {
        path: '/metrics',
        port: 8080,
      },
    },
  ),
)
+ test.case.new(
  name='prometheus with custom path and port',
  test=test.expect.eqDiff(
    actual=(application.withPrometheus(path='/kommuneinfo/v1/metrics', port=5000)).application.spec,
    expected={
      prometheus: {
        path: '/kommuneinfo/v1/metrics',
        port: 5000,
      },
    },
  ),
)
+ test.case.new(
  name='prometheus with allowAllMetrics true',
  test=test.expect.eqDiff(
    actual=(application.withPrometheus(path='/actuator/prometheus', port=8081, allowAllMetrics=true)).application.spec,
    expected={
      prometheus: {
        path: '/actuator/prometheus',
        port: 8081,
        allowAllMetrics: true,
      },
    },
  ),
)
+ test.case.new(
  name='prometheus with direct object syntax',
  test=test.expect.eqDiff(
    actual=(application.new('test', 'test:1.0', 8080) + {
      application+: {
        spec+: {
          prometheus: {
            path: '/metrics',
            port: 8080,
          },
        },
      },
    }).application.spec,
    expected={
      image: 'test:1.0',
      port: 8080,
      prometheus: {
        path: '/metrics',
        port: 8080,
      },
    },
  ),
)
