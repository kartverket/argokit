local argokit = import '../jsonnet/argokit.libsonnet';
local app = argokit.appAndObjects.application;

app.new('my-mount-app', 'nginx:latest', 8080)
+ app.withSecretAsMount(secretName='secret-test', mountPath='/my/secret/path')
+ app.withSecretAsMount(secretName='secret-test-restricted', mountPath='/my/restricted-secret/path', defaultMode=std.parseOctal('0600'))
+ app.withPersistentVolumeClaimAsMount(pvcName='pvc-test', mountPath='/my/pvc/path')
+ app.withEmptyDirAsMount(mountPath='/my/emptydir/path', emptyDir='volume-name')
