local accessPolicies = import '../lib/accessPolicies.libsonnet';
local environment = import '../lib/environment.libsonnet';
local ingress = import '../lib/ingress.libsonnet';
local replicas = import '../lib/replicas.libsonnet';

{
  accessPolicies: accessPolicies,
  environment: environment,
  replicas: replicas,
  ingress: ingress,
  application: {
    new(name): {
      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'Application',
      metadata: {
        name: name,
      },
    },
  },
  skipJob: {
    new(name): {
      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'SKIPJob',
      metadata: {
        name: name,
      },
    },
  },


  routing: {
    /**
      Creates a new routing
      Variables:
       - name: string - The name of the routing
       - hostname: string - The hostname of the server (your environment)
       - routes: array - an array of route objects defining the routes
    */
    new(name, hostname, routes): {
      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'Routing',
      metadata: {
        name: name,
      },
      spec: {
        hostname: hostname,
        routes: routes,
      },
    },
    route(pathPrefix, targetApp, rewriteUri):: {
      pathPrefix: pathPrefix,
      targetApp: targetApp,
      rewriteUri: rewriteUri,
    },
  },
}
