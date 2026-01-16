local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;

application.new('my-app', 'my-app:1.0.0', 8080)
+ application.withPrometheus(
  path='/metrics',
  port=8080
)
