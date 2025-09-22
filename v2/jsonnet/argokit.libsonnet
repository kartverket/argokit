local accessPolicies = import '../lib/accessPolicies.libsonnet';
local environment = import '../lib/environment.libsonnet';
local ingress = import '../lib/ingress.libsonnet';
local probes = import '../lib/probes.libsonnet';
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
  } + probes,

  skipJob: {
    new(name): {
      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'SKIPJob',
      metadata: {
        name: name,
      },
    },
  } + probes,

  routing: {
    /**
      Creates a new routing
      Variables:
       - name: string - The name of the routing
       - hostname: string - The hostname of the server (your environment)
       - routes: array - an array of route objects defining the routes
    */
    new(name, hostname, routes, redirectToHTTPS=true): {
      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'Routing',
      metadata: {
        name: name,
      },
      spec: {
        redirectToHTTPS: redirectToHTTPS,
        hostname: hostname,
        routes: routes,
      },
    },
    route(pathPrefix, targetApp, rewriteUri, port=''):: {
      pathPrefix: pathPrefix,
      targetApp: targetApp,
      rewriteUri: rewriteUri,
      [if port != '' then 'port']: port,
    },
  },
}
