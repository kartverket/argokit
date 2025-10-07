local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;
local secrets = [
  {
    fromSecret: 'the-first-test-file',
    toKey: 'test-key',
  },
];
local allKeysFrom = [
  {
    fromSecret: 'test-file',
  },
];

local actual =
  application.new('test-app')
  + application.withEnvironmentVariablesFromExternalSecret('test-external-secret', secrets=secrets, allKeysFrom=allKeysFrom);
local app = actual.items[0];
local externalSecret = actual.items[1];
local label = 'Test External Secret';

test.new(std.thisFile)
+ test.case.new(
  name=label + 'external secret kind is set',
  test=test.expect.eqDiff(
    actual=externalSecret.kind,
    expected='ExternalSecret'
  )
)
+ test.case.new(
  name=label + 'skip app kind is set',
  test=test.expect.eqDiff(
    actual=app.kind,
    expected='Application',
  )
)
+ test.case.new(
  name=label + 'external secret has correct target name',
  test=test.expect.eqDiff(
    actual=app.spec.envFrom[0].secret,
    expected=externalSecret.spec.target.name,
  )
)
+ test.case.new(
  name=label + 'external secret has correct metadata name',
  test=test.expect.eqDiff(
    actual=app.spec.envFrom[0].secret,
    expected=externalSecret.metadata.name,
  )
)
