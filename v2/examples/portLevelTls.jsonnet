local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;

application.new('my-service', 'myapp:1.0.0', 8080)
+ application.withPortLevelTls(
  host='my-pod.my-headless-svc',
  port=7800,
  tlsMode='ISTIO_MUTUAL'
)
