local argokit = import '../jsonnet/argokit.libsonnet';
local app = argokit.appAndObjects.application;

app.new('my-mount-app', 'nginx:latest', 8080)
+ app.withSecretAsMount(secretName='secret-test',mountPath='/my/secret/path')
+ app.withPersistentVolumeClaimAsMount(pvcName='pvc-test',mountPath='/my/pvc/path')
+ app.withEmptyDirAsMount(mountPath='/my/emptydir/path', emptyDir='')