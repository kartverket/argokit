local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;

test.new(std.thisFile)
+ test.case.new(
  name='Setup complete replica set',
  test=test.expect.eqDiff(
    actual=application.withReplicas(2, 4, 80, 90).application.spec,
    expected={
      replicas: {
        max: 4,
        min: 2,
        targetCpuUtilization: 80,
        targetMemoryUtilization: 90,
      },
    },
  ),
)
+ test.case.new(
  name='Setup replica without targetMemoryUtilization',
  test=test.expect.eqDiff(
    actual=application.withReplicas(2, 4, 50).application.spec,
    expected={
      replicas: {
        max: 4,
        min: 2,
        targetCpuUtilization: 50,
      },
    },
  ),
)
+ test.case.new(
  name='Setup static replica set',
  test=test.expect.eqDiff(
    actual=application.withReplicas(2).application.spec,
    expected={
      replicas: 2,
    },
  ),
)
