local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;

application.new('kommuneinfo', 'kommuneinfo:1.0.0', 5000)
+ application.withPrometheus(
  path='/kommuneinfo/v1/metrics',
  port=5000
)
