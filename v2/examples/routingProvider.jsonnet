local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;

// The Application uses the Kubernetes Gateway API instead of Istio Gateway and VirtualService.
application.new('testapp', 'foo.io/image', 8080)
+ application.forHostnames('testapp.atkv3-dev.kartverket-intern.cloud')
+ application.withRoutingProvider('Standard')
