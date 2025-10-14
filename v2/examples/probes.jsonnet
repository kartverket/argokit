local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;  // simplify statements

local livenessProbe = application.probe(path='/health', port=8080, failureThreshold=5, timeout=0, initialDelay=5);
local readinessProbe = application.probe(path='/health', port=8080);

application.new('testapp', 'foo.io/image', 8080)
+ application.withLiveness(livenessProbe)
+ application.withReadiness(readinessProbe)
+ application.withStartup(livenessProbe)
