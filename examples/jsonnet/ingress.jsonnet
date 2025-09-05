
local argokit = import '../../../argokit/jsonnet/argokit.libsonnet';
argokit.Application('testapp')
+argokit.Ingress.forHostnames(import 'ingress/database-ingress')
+argokit.Ingress.forHostnames([
  import 'ingress/api-ingress',
  "argokit-frontend-dev.devserver.kartverket-intern.cloud"]
)