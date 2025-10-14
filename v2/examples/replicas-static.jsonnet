local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;  // simplify statements

application.new('testapp', 'foo.io/image', 8080)
+ application.withReplicas(4)
