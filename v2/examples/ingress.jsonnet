
local argokit = import '../jsonnet/argokit.libsonnet';
argokit.application.new('testapp')
+argokit.application.forHostnames(import 'ingress/database-ingress')
+argokit.application.forHostnames([
  import 'ingress/api-ingress',
  "argokit-frontend-dev.devserver.kartverket-intern.cloud"]
)
+argokit.application.forHostnames(
  [
    "grunnbok.atkv3-prod.kartverket-intern.cloud",
    {
       "hostname":  "api.grunnbok.no",
       "customCert": "grunbok-star-cert"
    }
  ]
)