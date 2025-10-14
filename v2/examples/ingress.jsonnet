local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;  // simplify statements

application.new('testapp', 'foo.io/image', 8080)
+ application.forHostnames(import 'ingress/database-ingress')
+ application.forHostnames(
  [
    import 'ingress/api-ingress',
    'argokit-frontend-dev.devserver.kartverket-intern.cloud',
  ]
)
+ application.forHostnames(
  [
    import 'ingress/api-ingress',
    'argokit-frontend-dev.devserver.kartverket-intern.cloud',
  ]
)
+ application.forHostnames(
  [
    'grunnbok.atkv3-prod.kartverket-intern.cloud',
    {
      hostname: 'api.grunnbok.no',
      customCert: 'grunbok-star-cert',
    },
  ]
)
