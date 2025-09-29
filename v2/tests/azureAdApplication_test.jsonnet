local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';


local expectedOutput = {
  apiVersion: 'v1',
  items: [
    {
      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'Application',
      metadata: {
        name: 'test-app',
      },
      spec: {
        accessPolicy: {
          outbound: {
            external: [
              {
                host: 'login.microsoftonline.com',
              },
            ],
          },
        },
        envFrom: [
          {
            secret: 'azuread-test-name',
          },
        ],
      },
    },
    {
      apiVersion: 'nais.io/v1',
      kind: 'AzureAdApplication',
      metadata: {
        name: 'test-name',
        namespace: 'test-namespace',
      },
      spec: {
        allowAllUsers: false,
        claims: {
          groups: [
            'test-group',
          ],
        },
        logoutUrl: 'test-logout.url',
        preAuthorizedApplications: [
          {
            application: 'other-app',
            cluster: 'atgcp1-dev',
            namespace: 'other-namespace',
          },
        ],
        replyUrls: [
          {
            url: 'test-reply.url',
          },
          {
            url: 'http://localhost/callback',
          },
        ],
        secretName: 'azuread-test-name',
      },
    },
  ],
  kind: 'List',
};

local actual =
  argokit.application.new('test-app')
  + argokit.application.withAzureAdApplication(
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


test.new(std.thisFile)
+ test.case.new(
  name='Test AzureAdApplication',
  test=test.expect.eqDiff(
    actual=actual,
    expected=expectedOutput
  )
)
