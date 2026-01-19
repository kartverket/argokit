local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;

application.new('testapp', 'foo.io/image', 8080)
+ application.withReplicas(initial=3, max=8, targetMemoryUtilization=50)
