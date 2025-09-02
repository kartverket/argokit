
local argokit = import '../../../argokit/jsonnet/argokit.libsonnet';
argokit.Application('testapp')
+argokit.Ingress.ingress(import 'ingress/database-ingress')
+argokit.Ingress.ingress(import 'ingress/api-ingress')