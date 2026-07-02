local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;

application.new('extra-containers', 'image', 8080)
+ application.withExtraContainer(
  name='logging-agent',
  image='logging-agent:1.0',
  env=[
    {
      name: 'LOG_LEVEL',
      value: 'info',
    },
  ],
)
+ application.withExtraContainer(
  name='auth-proxy',
  image='auth-proxy:1.0',
  type='init',
  ingressPort=8443,
  additionalPorts=[
    {
      name: 'proxy',
      port: 8443,
      protocol: 'TCP',
    },
  ],
)
