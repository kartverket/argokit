
local argokit = import '../jsonnet/argokit.libsonnet';
argokit.application.new('testapp')
+argokit.ingress.forHostnames(import 'ingress/database-ingress')
+argokit.ingress.forHostnames([
  import 'ingress/api-ingress',
  "argokit-frontend-dev.devserver.kartverket-intern.cloud"]
)