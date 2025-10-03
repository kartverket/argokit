local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

test.new(std.thisFile)
+ test.case.new(
  name='readiness probe',
  test=test.expect.eqDiff(
    actual=(argokit.appAndObjects.skipJob.new('a-job') + argokit.application.withLiveness(argokit.application.probe(path='/health', port=8080, failureThreshold=5, timeout=0, initialDelay=5))).items[0].spec,
    expected={
      container: {
        liveness: {
          failureThreshold: 5,
          initialDelay: 5,
          path: '/health',
          port: 8080,
          timeout: 0,
        },
      },
    }
  ),
)
+ test.case.new(
  name='liveness probe',
  test=test.expect.eqDiff(
    actual=(argokit.appAndObjects.application.new('application') + argokit.application.withReadiness(argokit.application.probe(path='/health', port=8080))).items[0].spec,
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
    actual=(argokit.appAndObjects.application.new('application') + argokit.application.withStartup(argokit.application.probe(path='/health', port=8080))).items[0].spec,
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
