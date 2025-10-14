local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;  // simplify statements

application.new('test', 'foo.io/image', 8080)
+ application.withAzureAdApplication(
  name='testapp',
  namespace='tilgangsstyring-main',
  groups=['2720e397-081d-4d9b-852e-0d81f45a304f'],
  replyUrls=['https://test-app.atgcp1-sandbox.kartverket-intern.cloud/oauth2/callback'],
  preAuthorizedApplications=[{
    application: 'other-app',
    namespace: 'other-namespace',
    cluster: 'atgcp1-dev',
  }]
)
