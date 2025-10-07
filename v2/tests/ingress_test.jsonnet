local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;

test.new(std.thisFile)
+ test.case.new(
  name='Single ingress',
  test=test.expect.eqDiff(
    actual=application.forHostnames('hostName.kartverket.no').application.spec,
    expected={
      ingresses: [
        'hostName.kartverket.no',
      ],
    }
  ),
)
+ test.case.new(
  name='Multiple ingresses',
  test=test.expect.eqDiff(
    actual=application.forHostnames(['hostName.kartverket.no', 'hostName2.kartverket.no']).application.spec,
    expected={
      ingresses: [
        'hostName.kartverket.no',
        'hostName2.kartverket.no',
      ],
    }
  ),
)
+ test.case.new(
  name='Multiple ingresses with objects',
  test=test.expect.eqDiff(
    actual=application.forHostnames([
      'hostName.kartverket.no',
      {
        hostname: 'hostNameWithCustomCert.kartverket.no',
        customCert: 'grunnbok-star-cert',
      },
      {
        hostname: 'hostNameWithoutCustomCert.kartverket.no',
      },
    ]).application.spec,
    expected={
      ingresses: [
        'hostName.kartverket.no',
        'hostNameWithCustomCert.kartverket.no+grunnbok-star-cert',
        'hostNameWithoutCustomCert.kartverket.no',
      ],
    }
  ),
)
