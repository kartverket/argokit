local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;

test.new(std.thisFile)
+ test.case.new(
  name='readiness probe',
  test=test.expect.eqDiff(
    actual=(application.withLiveness(application.probe(path='/health', port=8080, failureThreshold=5, timeout=0, initialDelay=5))).application.spec,
    expected={
      liveness: {
        failureThreshold: 5,
        initialDelay: 5,
        path: '/health',
        port: 8080,
        timeout: 0,
      },
    },
  ),
)
+ test.case.new(
  name='liveness probe',
  test=test.expect.eqDiff(
    actual=(application.withReadiness(application.probe(path='/health', port=8080))).application.spec,
    expected={
      readiness: {
        failureThreshold: 3,
        initialDelay: 0,
        path: '/health',
        port: 8080,
        timeout: 1,
      },
    }
  ),
)
+ test.case.new(
  name='startup probe',
  test=test.expect.eqDiff(
    actual=(application.withStartup(application.probe(path='/health', port=8080))).application.spec,
    expected={
      startup: {
        failureThreshold: 3,
        initialDelay: 0,
        path: '/health',
        port: 8080,
        timeout: 1,
      },
    }
  ),
)
