local v = import '../internal/validation.libsonnet';
{
  /**
  Creates ingresses.
  Parameters:
  - ingress: [string|object{hostname, customCert?}] - Ingress may be a string containing the hostname, an import statement for a file containing the hostname or an object with this structure: {hostname: 'hostname', customCert: 'certificate filename'}
  See examples or tests to understand how to use this function.
  */
  forHostnames(ingress):
    v.require(std.isArray(ingress) || std.isString(ingress), 'ingress must be a string or an array') +
    {
      local handleIngress(ingress) = if std.isString(ingress) then ingress else if (std.objectHas(ingress, 'customCert')) then ingress.hostname + '+' + ingress.customCert else ingress.hostname,

      application+: {
        spec+: {
          ingresses+: if std.isArray(ingress) then std.map(handleIngress, ingress) else [handleIngress(ingress)],
        },
      },
    },

  /**
  Selects the routing API Skiperator uses for the ingresses of the Application.
  Parameters:
  - routingProvider: string - Standard (recommended) uses the Kubernetes Gateway API. Legacy (default) uses Istio Gateway and VirtualService.
  Legacy is removed at a later date, so we encourage users to move to Standard.
  Note: spec.istioSettings.retries is not supported with Standard.
  */
  withRoutingProvider(routingProvider='Legacy'):
    v.enum(routingProvider, 'routingProvider', ['Legacy', 'Standard']) +
    {
      application+: {
        spec+: {
          routingProvider: routingProvider,
        },
      },
    },
}
