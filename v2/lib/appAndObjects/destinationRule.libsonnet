local v = import '../../internal/validation.libsonnet';

{
  /**
   * Creates an Istio DestinationRule for sticky sessions using consistent hash load balancing.
   * This enables session affinity by routing requests from the same client to the same pod.
   * 
   * Parameters:
   *  - cookieName: string (optional, default='ISTIO-STICKY') - The name of the cookie to use for sticky sessions
   *  - cookiePath: string (optional, default=null) - The path for the cookie. If not set, path is omitted from the cookie config
   *  - cookieTtl: string (optional, default='0') - The TTL for the cookie (0 means session cookie)
   */
  withStickySession(cookieName='ISTIO-STICKY', cookiePath=null, cookieTtl='0')::
    v.string(cookieName, 'cookieName') +
    v.string(cookieTtl, 'cookieTtl') +
    (if cookiePath != null then v.string(cookiePath, 'cookiePath') else {}) +
    {
      local name = self.application.metadata.name,
      objects+: [
        {
          apiVersion: 'networking.istio.io/v1alpha3',
          kind: 'DestinationRule',
          metadata: {
            name: 'istio-sticky-' + name,
          },
          spec: {
            host: name,
            trafficPolicy: {
              loadBalancer: {
                consistentHash: {
                  httpCookie: std.prune({
                    name: cookieName,
                    [if cookiePath != null then 'path']: cookiePath,
                    ttl: cookieTtl,
                  }),
                },
              },
            },
          },
        },
      ],
    },

  /**
   * Creates an Istio DestinationRule for port-level TLS configuration.
   * This enables TLS for specific ports on a service.
   * 
   * Parameters:
   *  - host: string (required) - The target host (can be simple hostname or formatted like 'pod.service')
   *  - port: number (optional, default=443) - The port number for TLS configuration
   *  - tlsMode: string (optional, default='SIMPLE') - The TLS mode (ISTIO_MUTUAL, SIMPLE, MUTUAL, DISABLE)
   *  - name: string (optional, default=null) - Custom name for the DestinationRule (defaults to application name)
   */
  withPortLevelTls(host, port=443, tlsMode='SIMPLE', name=null)::
    v.string(host, 'host') +
    v.number(port, 'port') +
    v.string(tlsMode, 'tlsMode') +
    (if name != null then v.string(name, 'name') else {}) +
    {
      local appName = self.application.metadata.name,
      objects+: [
        {
          apiVersion: 'networking.istio.io/v1',
          kind: 'DestinationRule',
          metadata: {
            name: if name != null then name else appName,
          },
          spec: {
            host: host,
            trafficPolicy: {
              portLevelSettings: [
                {
                  port: {
                    number: port,
                  },
                  tls: {
                    mode: tlsMode,
                  },
                },
              ],
            },
          },
        },
      ],
    },

  /**
   * Creates an Istio DestinationRule with traffic policy TLS configuration.
   * This configures TLS settings for outbound traffic to external services with SNI support.
   * 
   * Parameters:
   *  - name: string (required) - The name for the DestinationRule
   *  - host: string (required) - The external host
   *  - tlsMode: string (optional, default='SIMPLE') - The TLS mode (SIMPLE, MUTUAL, ISTIO_MUTUAL, DISABLE)
   *  - sni: string (optional, default=null) - The SNI string to present to the server during TLS handshake
   */
  withTrafficPolicyTls(name, host, tlsMode='SIMPLE', sni=null)::
    v.string(name, 'name') +
    v.string(host, 'host') +
    v.string(tlsMode, 'tlsMode') +
    (if sni != null then v.string(sni, 'sni') else {}) +
    {
      objects+: [
        {
          apiVersion: 'networking.istio.io/v1',
          kind: 'DestinationRule',
          metadata: {
            name: name,
          },
          spec: {
            host: host,
            trafficPolicy: {
              tls: std.prune({
                mode: tlsMode,
                [if sni != null then 'sni']: sni,
              }),
            },
          },
        },
      ],
    },
}
