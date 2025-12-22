local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;

test.new(std.thisFile)

// =====================
// withRequests tests
// =====================
+ test.case.new(
  name='withRequests - cpu and memory string',
  test=test.expect.eqDiff(
    actual=(application.resources.withRequests(cpu='100m', memory='128Mi')).application.spec.resources,
    expected={
      requests: {
        cpu: '100m',
        memory: '128Mi',
      },
    },
  ),
)
+ test.case.new(
  name='withRequests - cpu only',
  test=test.expect.eqDiff(
    actual=(application.resources.withRequests(cpu='500m')).application.spec.resources,
    expected={
      requests: {
        cpu: '500m',
      },
    },
  ),
)
+ test.case.new(
  name='withRequests - memory only',
  test=test.expect.eqDiff(
    actual=(application.resources.withRequests(memory='256Mi')).application.spec.resources,
    expected={
      requests: {
        memory: '256Mi',
      },
    },
  ),
)
+ test.case.new(
  name='withRequests - cpu as number',
  test=test.expect.eqDiff(
    actual=(application.resources.withRequests(cpu=1, memory='128Mi')).application.spec.resources,
    expected={
      requests: {
        cpu: 1,
        memory: '128Mi',
      },
    },
  ),
)
+ test.case.new(
  name='withRequests - cpu as string number (no suffix)',
  test=test.expect.eqDiff(
    actual=(application.resources.withRequests(cpu='0.5', memory='128Mi')).application.spec.resources,
    expected={
      requests: {
        cpu: '0.5',
        memory: '128Mi',
      },
    },
  ),
)
+ test.case.new(
  name='withRequests - memory with Gi suffix',
  test=test.expect.eqDiff(
    actual=(application.resources.withRequests(cpu='100m', memory='1Gi')).application.spec.resources,
    expected={
      requests: {
        cpu: '100m',
        memory: '1Gi',
      },
    },
  ),
)
+ test.case.new(
  name='withRequests - memory as number',
  test=test.expect.eqDiff(
    actual=(application.resources.withRequests(cpu='100m', memory=134217728)).application.spec.resources,
    expected={
      requests: {
        cpu: '100m',
        memory: 134217728,
      },
    },
  ),
)

// =====================
// withLimits tests
// =====================
+ test.case.new(
  name='withLimits - cpu and memory string',
  test=test.expect.eqDiff(
    actual=(application.resources.withLimits(cpu='500m', memory='512Mi')).application.spec.resources,
    expected={
      limits: {
        cpu: '500m',
        memory: '512Mi',
      },
    },
  ),
)
+ test.case.new(
  name='withLimits - cpu only',
  test=test.expect.eqDiff(
    actual=(application.resources.withLimits(cpu='1')).application.spec.resources,
    expected={
      limits: {
        cpu: '1',
      },
    },
  ),
)
+ test.case.new(
  name='withLimits - memory only',
  test=test.expect.eqDiff(
    actual=(application.resources.withLimits(memory='2Gi')).application.spec.resources,
    expected={
      limits: {
        memory: '2Gi',
      },
    },
  ),
)

// =====================
// Combined requests and limits
// =====================
+ test.case.new(
  name='withRequests and withLimits combined',
  test=test.expect.eqDiff(
    actual=(
      application.resources.withRequests(cpu='100m', memory='128Mi')
      + application.resources.withLimits(cpu='500m', memory='512Mi')
    ).application.spec.resources,
    expected={
      requests: {
        cpu: '100m',
        memory: '128Mi',
      },
      limits: {
        cpu: '500m',
        memory: '512Mi',
      },
    },
  ),
)

// =====================
// All valid memory suffixes
// =====================
+ test.case.new(
  name='memory suffix - Mi',
  test=test.expect.eqDiff(
    actual=(application.resources.withRequests(memory='128Mi')).application.spec.resources.requests.memory,
    expected='128Mi',
  ),
)
+ test.case.new(
  name='memory suffix - Gi',
  test=test.expect.eqDiff(
    actual=(application.resources.withRequests(memory='1Gi')).application.spec.resources.requests.memory,
    expected='1Gi',
  ),
)
+ test.case.new(
  name='memory suffix - Ki',
  test=test.expect.eqDiff(
    actual=(application.resources.withRequests(memory='1024Ki')).application.spec.resources.requests.memory,
    expected='1024Ki',
  ),
)
+ test.case.new(
  name='memory suffix - M (decimal)',
  test=test.expect.eqDiff(
    actual=(application.resources.withRequests(memory='128M')).application.spec.resources.requests.memory,
    expected='128M',
  ),
)
+ test.case.new(
  name='memory suffix - G (decimal)',
  test=test.expect.eqDiff(
    actual=(application.resources.withRequests(memory='1G')).application.spec.resources.requests.memory,
    expected='1G',
  ),
)
+ test.case.new(
  name='memory suffix - k (decimal)',
  test=test.expect.eqDiff(
    actual=(application.resources.withRequests(memory='1024k')).application.spec.resources.requests.memory,
    expected='1024k',
  ),
)
