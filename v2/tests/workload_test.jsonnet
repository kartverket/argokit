local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;

test.new(std.thisFile)
+ test.case.new(
  name='common workload helpers are available for application',
  test=test.expect.eqDiff(
    actual=(
      application.withCommand(['run'])
      + application.withLabels({ custom: 'test-label' })
      + application.withTeam('team-a')
      + application.withPriority('high')
      + application.withAdditionalPort('metrics', 9090)
      + application.withPodSettings(annotations={ sidecar: 'disabled' }, terminationGracePeriodSeconds=60)
      + application.withTracing(75)
    ).application.spec,
    expected={
      command: [
        'run',
      ],
      labels: {
        custom: 'test-label',
      },
      team: 'team-a',
      priority: 'high',
      additionalPorts: [
        {
          name: 'metrics',
          port: 9090,
          protocol: 'TCP',
        },
      ],
      podSettings: {
        annotations: {
          sidecar: 'disabled',
        },
        terminationGracePeriodSeconds: 60,
      },
      istioSettings: {
        telemetry: {
          tracing: [
            {
              randomSamplingPercentage: 75,
            },
          ],
        },
      },
    },
  ),
)
