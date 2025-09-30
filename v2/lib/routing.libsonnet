{
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
}
