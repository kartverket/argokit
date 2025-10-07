local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application; // simplify statements

application.new('testapp')
+ application.withReplicas(
    initial=3,
    max=6,
    targetCpuUtilization=50)
