local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

local store = argokit.secrets.store.new('test-gsm-store');
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
    actual=store.spec.provider.gcpsm.projectID,
    expected='test-gsm-store'
  )
)
