local v = import '../internal/validation.libsonnet';
{
  new(name, hostname, redirectToHTTPS=true)::
    v.string(name, 'name') +
    v.string(hostname, 'hostname') +
    v.boolean(redirectToHTTPS, 'redirectToHTTPS') +
    {
      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'Routing',
      metadata: {
        name: name,
      },
      spec: {
        redirectToHTTPS: redirectToHTTPS,
        hostname: hostname,
        routes: [],
      },
    },
  withRoute(pathPrefix, targetApp, rewriteUri, port=null)::
    v.string(pathPrefix, 'pathPrefix') +
    v.string(targetApp, 'targetApp') +
    v.boolean(rewriteUri, 'rewriteUri') +
    v.number(port, 'port', allowNull=true) +

    local r = std.prune({
      pathPrefix: pathPrefix,
      targetApp: targetApp,
      rewriteUri: rewriteUri,
      port: port,
    });
    {
      spec+: {
        routes+: [r],
      },
    },
}
