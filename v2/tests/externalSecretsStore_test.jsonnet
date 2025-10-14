local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

local store = argokit.externalSecrets.store.new(name='test-gsm-store', gcpProject='proj-id');
local label = 'Test External Secret Store';

test.new(std.thisFile)
+ test.case.new(
  name=label + 'external secret kind is set',
  test=test.expect.eqDiff(
    actual=store.kind,
    expected='SecretStore'
  )
)
+ test.case.new(
  name=label + 'projectID is the same as argument',
  test=test.expect.eqDiff(
    actual=store.metadata.name,
    expected='test-gsm-store'
  )
)
+ test.case.new(
  name=label + 'projectID is the same as argument',
  test=test.expect.eqDiff(
    actual=store.spec.provider.gcpsm.projectID,
    expected='proj-id'
  )
)
