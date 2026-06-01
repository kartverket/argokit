local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;
test.new(std.thisFile)
+ test.case.new(
  name='Service account to be set',
  test=test.expect.eqDiff(
    actual=(application.withGcpServiceAccount('something@google.com')).application.spec,
    expected={
      gcp: {
        auth: {
          serviceAccount: 'something@google.com',
        },
      },
    },
  ),
)
+ test.case.new(
  name='Cloud SQL proxy can be combined with service account',
  test=test.expect.eqDiff(
    actual=(
      application.withGcpServiceAccount('something@google.com')
      + application.withCloudSqlProxy(
        connectionName='project:europe-north1:instance',
        serviceAccount='cloudsql@google.com',
        ip='10.0.0.1',
      )
    ).application.spec,
    expected={
      gcp: {
        auth: {
          serviceAccount: 'something@google.com',
        },
        cloudSqlProxy: {
          connectionName: 'project:europe-north1:instance',
          serviceAccount: 'cloudsql@google.com',
          ip: '10.0.0.1',
        },
      },
    },
  ),
)
