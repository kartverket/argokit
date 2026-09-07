local utils = import '../../internal/utils.libsonnet';
local v = import '../../internal/validation.libsonnet';

{
  /**
  Builds a Routing object.
  Parameters:
  - name: string - name of the Routing object.
  - hostname: string - the hostname to route.
  - redirectToHTTPS: boolean - redirect HTTP traffic to HTTPS. Default true.
  - routingProvider: string - Standard (recommended) uses the Kubernetes Gateway API. Legacy (default) uses Istio Gateway and VirtualService.
  Legacy is removed at a later date, so we encourage users to move to Standard.
  - ownership: string - Standalone (default) owns the whole hostname. Shared adds paths to a hostname that other Routing objects also use.
  Shared requires routingProvider Standard and a hostname without a custom certificate.
  */
  new(name, hostname, redirectToHTTPS=true, routingProvider='Legacy', ownership='Standalone')::
    v.string(name, 'name') +
    v.string(hostname, 'hostname') +
    v.boolean(redirectToHTTPS, 'redirectToHTTPS') +
    v.enum(routingProvider, 'routingProvider', ['Legacy', 'Standard']) +
    v.enum(ownership, 'ownership', ['Standalone', 'Shared']) +
    v.require(ownership != 'Shared' || routingProvider == 'Standard', 'ownership Shared requires routingProvider Standard') +
    v.require(ownership != 'Shared' || std.length(std.findSubstr('+', hostname)) == 0, 'ownership Shared cannot use a custom certificate secret; the certificate is shared per hostname') +
    {
      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'Routing',
      metadata: {
        name: name,
      },
      spec: {
        redirectToHTTPS: redirectToHTTPS,
        hostname: hostname,
        routingProvider: routingProvider,
        ownership: ownership,
        routes: [],
      },
    } + utils.withArgokitVersionLabel(flavor='v2'),
  withRoute(pathPrefix, targetApp, rewriteUri, port=null)::
    v.string(pathPrefix, 'pathPrefix') +
    v.string(targetApp, 'targetApp') +
    v.boolean(rewriteUri, 'rewriteUri') +
    v.number(port, 'port', allowNull=true) +

    {
      spec+: {
        routes+: std.prune([
          {
            pathPrefix: pathPrefix,
            targetApp: targetApp,
            rewriteUri: rewriteUri,
            port: port,
          },
        ]),
      },
    },
}
