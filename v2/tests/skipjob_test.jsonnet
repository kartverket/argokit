local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local skipjob = argokit.appAndObjects.skipjob;

local command = [
  'perl',
  '-Mbignum=bpi',
  '-wle',
  'print bpi(2000)',
];

local skipjobWithConfigMapAsEnv =
  skipjob.new('job', 'foo.io/image')
  + skipjob.withConfigMapAsEnv(name='settings', data={ PORT: 3333 });

local skipjobWithConfigMapAsMount =
  skipjob.new('job', 'foo.io/image')
  + skipjob.withConfigMapAsMount(name='settings', mountPath='/etc/settings', data={ PORT: 3333 });

local skipjobWithExternalSecret =
  skipjob.new('job', 'foo.io/image')
  + skipjob.withEnvironmentVariablesFromExternalSecret(
    name='runtime-secrets',
    secrets=[
      {
        fromSecret: 'remote-secret',
        toKey: 'PASSWORD',
      },
    ],
    secretStoreRef='some-store',
  );

test.new(std.thisFile)
+ test.case.new(
  name='minimal v1beta1 skipjob',
  test=test.expect.eqDiff(
    actual=(skipjob.new('minimal-job', 'perl:5.34.0') + skipjob.withCommand(command)).application,
    expected={
      apiVersion: 'skiperator.kartverket.no/v1beta1',
      kind: 'SKIPJob',
      metadata: {
        name: 'minimal-job',
      },
      spec: {
        image: 'perl:5.34.0',
        command: command,
      },
    },
  ),
)
+ test.case.new(
  name='cron with timezone',
  test=test.expect.eqDiff(
    actual=(skipjob.withCron(schedule='* * * * *', timeZone='Europe/Oslo')).application.spec,
    expected={
      cron: {
        schedule: '* * * * *',
        timeZone: 'Europe/Oslo',
      },
    },
  ),
)
+ test.case.new(
  name='settings backoff zero is preserved',
  test=test.expect.eqDiff(
    actual=(skipjob.withSettings(backoffLimit=0)).application.spec,
    expected={
      job: {
        backoffLimit: 0,
      },
    },
  ),
)
+ test.case.new(
  name='access policy is available for skipjob',
  test=test.expect.eqDiff(
    actual=(skipjob.withOutboundSkipApp('minimal-application') + skipjob.withOutboundHttp(host='example.com', portname='http', port=80, protocol='HTTP')).application.spec,
    expected={
      accessPolicy: {
        outbound: {
          rules: [
            {
              application: 'minimal-application',
            },
          ],
          external: [
            {
              host: 'example.com',
            },
          ],
        },
      },
    },
  ),
)
+ test.case.new(
  name='cloud sql proxy is available for skipjob',
  test=test.expect.eqDiff(
    actual=(skipjob.withCloudSqlProxy(
              connectionName='test-project-bda1:europe-north1:pg-01-test',
              serviceAccount='my-sa@test-project-bda1.iam.gserviceaccount.com',
              ip='10.0.0.1',
            )).application.spec,
    expected={
      gcp: {
        cloudSqlProxy: {
          connectionName: 'test-project-bda1:europe-north1:pg-01-test',
          serviceAccount: 'my-sa@test-project-bda1.iam.gserviceaccount.com',
          ip: '10.0.0.1',
        },
      },
    },
  ),
)
+ test.case.new(
  name='prometheus is available for skipjob',
  test=test.expect.eqDiff(
    actual=(skipjob.withPrometheus(path='/metrics', port=8080)).application.spec,
    expected={
      prometheus: {
        path: '/metrics',
        port: 8080,
        scrapeInterval: '60s',
      },
    },
  ),
)
+ test.case.new(
  name='environment helpers are available for skipjob',
  test=test.expect.eqDiff(
    actual=(
      skipjob.withEnvironmentVariable('REDIS_PORT', '6379')
      + skipjob.withEnvironmentVariables({
        DATABASE_HOST: 'localhost',
      })
      + skipjob.withEnvironmentVariableFromSecret('PASSWORD', 'database-secret', 'password')
      + skipjob.withEnvironmentVariablesFromSecret('all-secrets')
    ).application.spec,
    expected={
      env: [
        {
          name: 'REDIS_PORT',
          value: '6379',
        },
        {
          name: 'DATABASE_HOST',
          value: 'localhost',
        },
        {
          name: 'PASSWORD',
          valueFrom: {
            secretKeyRef: {
              name: 'database-secret',
              key: 'password',
            },
          },
        },
      ],
      envFrom: [
        {
          secret: 'all-secrets',
        },
      ],
    },
  ),
)
+ test.case.new(
  name='external secret helper creates secret env for skipjob',
  test=test.expect.eqDiff(
    actual={
      appKind: skipjobWithExternalSecret.items[0].kind,
      envFromSecret: skipjobWithExternalSecret.items[0].spec.envFrom[0].secret,
      externalSecretKind: skipjobWithExternalSecret.items[1].kind,
      externalSecretStoreRef: skipjobWithExternalSecret.items[1].spec.secretStoreRef.name,
      externalSecretTargetName: skipjobWithExternalSecret.items[1].spec.target.name,
    },
    expected={
      appKind: 'SKIPJob',
      envFromSecret: 'runtime-secrets',
      externalSecretKind: 'ExternalSecret',
      externalSecretStoreRef: 'some-store',
      externalSecretTargetName: 'runtime-secrets',
    },
  ),
)
+ test.case.new(
  name='configmap env helper creates configmap env for skipjob',
  test=test.expect.eqDiff(
    actual={
      appKind: skipjobWithConfigMapAsEnv.items[0].kind,
      envFromConfigMap: skipjobWithConfigMapAsEnv.items[0].spec.envFrom[0].configMap,
      configMapKind: skipjobWithConfigMapAsEnv.items[1].kind,
      configMapName: skipjobWithConfigMapAsEnv.items[1].metadata.name,
    },
    expected={
      appKind: 'SKIPJob',
      envFromConfigMap: 'settings-configmap',
      configMapKind: 'ConfigMap',
      configMapName: 'settings-configmap',
    },
  ),
)
+ test.case.new(
  name='configmap mount helper creates configmap mount for skipjob',
  test=test.expect.eqDiff(
    actual={
      appKind: skipjobWithConfigMapAsMount.items[0].kind,
      filesFrom: skipjobWithConfigMapAsMount.items[0].spec.filesFrom[0],
      configMapKind: skipjobWithConfigMapAsMount.items[1].kind,
      configMapName: skipjobWithConfigMapAsMount.items[1].metadata.name,
    },
    expected={
      appKind: 'SKIPJob',
      filesFrom: {
        configMap: 'settings-configmap',
        mountPath: '/etc/settings',
      },
      configMapKind: 'ConfigMap',
      configMapName: 'settings-configmap',
    },
  ),
)
+ test.case.new(
  name='labels team and tracing',
  test=test.expect.eqDiff(
    actual=(
      skipjob.withLabels({ custom: 'test-label' })
      + skipjob.withTeam('fixed-team')
      + skipjob.withTracing(75)
    ).application.spec,
    expected={
      labels: {
        custom: 'test-label',
      },
      team: 'fixed-team',
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
+ test.case.new(
  name='pod settings additional port priority restart policy',
  test=test.expect.eqDiff(
    actual=(
      skipjob.withPodSettings(annotations={ sidecar: 'disabled' }, terminationGracePeriodSeconds=60)
      + skipjob.withAdditionalPort('metrics', 9090)
      + skipjob.withPriority('high')
      + skipjob.withRestartPolicy('OnFailure')
    ).application.spec,
    expected={
      podSettings: {
        annotations: {
          sidecar: 'disabled',
        },
        terminationGracePeriodSeconds: 60,
      },
      additionalPorts: [
        {
          name: 'metrics',
          port: 9090,
          protocol: 'TCP',
        },
      ],
      priority: 'high',
      restartPolicy: 'OnFailure',
    },
  ),
)
