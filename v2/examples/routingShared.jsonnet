local argokit = import '../jsonnet/argokit.libsonnet';

// Two applications in two namespaces share the hostname api.example.com.
// Each Routing object owns its own path prefix on that hostname.
// Shared ownership requires routingProvider 'Standard'.
// In an apps-repo each Routing usually gets its namespace from the ArgoCD
// destination. This example sets it directly to show both in one file.
local sharedRouting(name, namespace, pathPrefix, targetApp) =
  argokit.routing.new(
    name,
    'api.example.com',
    routingProvider='Standard',
    ownership='Shared',
  )
  + argokit.routing.withRoute(pathPrefix=pathPrefix, targetApp=targetApp, rewriteUri=false)
  + { metadata+: { namespace: namespace } };

{
  apiVersion: 'v1',
  kind: 'List',
  items: [
    sharedRouting('orders-routing', 'orders-dev', '/orders', 'orders-api'),
    sharedRouting('invoices-routing', 'invoices-dev', '/invoices', 'invoices-api'),
  ],
}
