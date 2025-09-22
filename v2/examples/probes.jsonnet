
local argokit = import '../jsonnet/argokit.libsonnet';

local livenessProbe = argokit.application.probe(path='/health', port=8080, failureThreshold=5, timeout=0, initialDelay=5 );
local readinessProbe = argokit.application.probe(path='/health', port=8080);

argokit.application.new('testapp')
+argokit.application.withLiveness(livenessProbe)
+argokit.application.withReadiness(readinessProbe)
+argokit.application.withStartup(livenessProbe)