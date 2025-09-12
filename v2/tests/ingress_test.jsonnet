local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

local ingress = argokit.ingress;

test.new(std.thisFile)
+ test.case.new(
  name='Single ingress',
  test=test.expect.eqDiff(
    actual=ingress.forHostnames('hostName.kartverket.no').spec,
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
    actual=ingress.forHostnames(['hostName.kartverket.no', 'hostName2.kartverket.no']).spec,
    expected={
      ingresses: [
        'hostName.kartverket.no',
        'hostName2.kartverket.no',
      ],
    }
  ),
)
+ test.case.new(
  name='Multiple ingresses',
  test=test.expect.eqDiff(
    actual=ingress.forHostnames(['hostName.kartverket.no', {hostname: 'hostNameWithCustomCert.kartverket.no', customCert: 'grunnbok-star-cert']).spec,
    expected={
      ingresses: [
        'hostName.kartverket.no',
        'hostNameWithCustomCert.kartverket.no+grunnbok-star-cert',
      ],
    }
  ),
)
