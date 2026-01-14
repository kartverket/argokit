local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;

local app = application.new('app', 'image', 8080);

local secretMountApp = app + application.withSecretAsMount('my-secret', '/var/run/secrets/my-secret');
local pvcMountApp = app + application.withPersistentVolumeClaimAsMount('my-pvc', '/var/data');
local combinedMountApp = 
  app 
  + application.withSecretAsMount('secret-1', '/path/1')
  + application.withPersistentVolumeClaimAsMount('pvc-1', '/path/2');

test.new(std.thisFile)

+ test.case.new(
  name='withSecretAsFileMount adds correct filesFrom entry',
  test=test.expect.eqDiff(
    actual=secretMountApp.items[0].spec.filesFrom[0],
    expected={
      mountPath: '/var/run/secrets/my-secret',
      secret: 'my-secret',
    }
  )
)

+ test.case.new(
  name='withPersistentVolumeClaimAsMount adds correct filesFrom entry',
  test=test.expect.eqDiff(
    actual=pvcMountApp.items[0].spec.filesFrom[0],
    expected={
      mountPath: '/var/data',
      persistentVolumeClaim: 'my-pvc',
    }
  )
)

+ test.case.new(
  name='combining mounts adds multiple filesFrom entries',
  test=test.expect.eqDiff(
    actual=combinedMountApp.items[0].spec.filesFrom,
    expected=[
      {
        mountPath: '/path/1',
        secret: 'secret-1',
      },
      {
        mountPath: '/path/2',
        persistentVolumeClaim: 'pvc-1',
      },
    ]
  )
)
