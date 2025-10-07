local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application; // simplify statements

application.new('testapp')
+ application.withReplicas(4)
