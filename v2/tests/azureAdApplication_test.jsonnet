local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;

local actual =
  application.new('test-app')
  + application.withAzureAdApplication(
    name='test-name',
    namespace='test-namespace',
    groups=['test-group'],
    secretPrefix='azuread',
    allowAllUsers=false,
    logoutUrl='test-logout.url',
    replyUrls=['test-reply.url'],
    preAuthorizedApplications=[{
      application: 'other-app',
      namespace: 'other-namespace',
      cluster: 'atgcp1-dev',
    }]
  );


local skipApp = actual.items[0];
local azureApp = actual.items[1];
local label = 'Test AzureAdApplication ';


test.new(std.thisFile)
+ test.case.new(
  name=label + 'envFrom matches secretName',
  test=test.expect.eqDiff(
    actual=skipApp.spec.envFrom[0].secret,
    expected=azureApp.spec.secretName,
  )
)

+ test.case.new(
  name=label + 'skiperator App has outbound microsoft',
  test=test.expect.eqDiff(
    actual=skipApp.spec.accessPolicy.outbound.external[0].host,
    expected='login.microsoftonline.com',
  )
)
+ test.case.new(
  name=label + 'azure app kind is set',
  test=test.expect.eqDiff(
    actual=azureApp.kind,
    expected='AzureAdApplication',
  )
)

+ test.case.new(
  name=label + 'skip app kind is set',
  test=test.expect.eqDiff(
    actual=skipApp.kind,
    expected='Application',
  )
)

+ test.case.new(
  name=label + ' item list is correct length',
  test=test.expect.eqDiff(
    actual=std.length(actual.items),
    expected=2,
  )
)

+ test.case.new(
  name=label + ' root object is correct kind',
  test=test.expect.eqDiff(
    actual=actual.kind,
    expected='List',
  )
)
