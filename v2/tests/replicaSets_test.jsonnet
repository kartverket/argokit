local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

local replicaSets = argokit.replicaSets;

test.new(std.thisFile)
+ test.case.new(
  name='Setup complete replica set',
  test=test.expect.eqDiff(
    actual=replicaSets.withReplicaSets(2, 4, 80, 90).spec,
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
  name='Setup replica set without targetMemoryUtilization',
  test=test.expect.eqDiff(
    actual=replicaSets.withReplicaSets(2, 4, 50).spec,
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
    actual=replicaSets.withReplicaSets(2).spec,
    expected={
      replicas: 2,
    },
  ),
)
