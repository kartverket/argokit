{
  /**
  Creates ingresses.
  Parameters:
  - ingress [string|import statement|object]: Ingress may be a string containing the hostname, an import statement for a file containing the hostname or an object with this structure: {hostname: 'hostname', customCert: 'certificate filename'}
  See examples or tests to understand how to use this function.
  */
  forHostnames(ingress): {
    local handleIngress(ingress) = if std.isString(ingress) then ingress else ingress.hostname + '+' + ingress.customCert,

    spec+: {
      ingresses+: if std.isArray(ingress) then std.map(handleIngress, ingress) else [handleIngress(ingress)],
    },
  },
}
