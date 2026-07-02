local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;

local app = application.new('app', 'image', 8080);

test.new(std.thisFile)
+ test.case.new(
  name='withExtraContainer adds standard container',
  test=test.expect.eqDiff(
    actual=(app + application.withExtraContainer(
      name='logging-agent',
      image='logging-agent:1.0',
      env=[
        {
          name: 'LOG_LEVEL',
          value: 'info',
        },
      ],
      filesFrom=[
        {
          mountPath: '/tmp',
          emptyDir: 'tmp',
        },
      ],
    )).application.spec.extraContainers,
    expected=[
      {
        name: 'logging-agent',
        image: 'logging-agent:1.0',
        type: 'standard',
        env: [
          {
            name: 'LOG_LEVEL',
            value: 'info',
          },
        ],
        filesFrom: [
          {
            mountPath: '/tmp',
            emptyDir: 'tmp',
          },
        ],
      },
    ],
  ),
)
+ test.case.new(
  name='withExtraContainer supports init type and ingressPort',
  test=test.expect.eqDiff(
    actual=(app + application.withExtraContainer(
      name='auth-proxy',
      image='auth-proxy:1.0',
      type='init',
      ingressPort=8443,
      additionalPorts=[
        {
          name: 'proxy',
          port: 8443,
          protocol: 'TCP',
        },
      ],
      args=[
        '--listen=:8443',
      ],
    )).application.spec.extraContainers,
    expected=[
      {
        name: 'auth-proxy',
        image: 'auth-proxy:1.0',
        type: 'init',
        ingressPort: 8443,
        additionalPorts: [
          {
            name: 'proxy',
            port: 8443,
            protocol: 'TCP',
          },
        ],
        args: [
          '--listen=:8443',
        ],
      },
    ],
  ),
)
+ test.case.new(
  name='withExtraContainers appends raw container specs',
  test=test.expect.eqDiff(
    actual=(app + application.withExtraContainers([
      application.extraContainer(
        name='config-loader',
        image='config-loader:1.0',
        type='init',
      ),
      {
        name: 'raw-sidecar',
        image: 'raw-sidecar:1.0',
        type: 'standard',
      },
    ])).application.spec.extraContainers,
    expected=[
      {
        name: 'config-loader',
        image: 'config-loader:1.0',
        type: 'init',
      },
      {
        name: 'raw-sidecar',
        image: 'raw-sidecar:1.0',
        type: 'standard',
      },
    ],
  ),
)
