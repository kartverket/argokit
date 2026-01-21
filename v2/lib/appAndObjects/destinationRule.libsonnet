local v = import '../../internal/validation.libsonnet';

{
  /**
   * Creates an Istio DestinationRule for sticky sessions using consistent hash load balancing.
   * This enables session affinity by routing requests from the same client to the same pod.
   * 
   * Parameters:
   *  - cookieName: string (optional, default='ISTIO-STICKY') - The name of the cookie to use for sticky sessions
   *  - cookiePath: string (optional, default='/') - The path for the cookie
   *  - cookieTtl: string (optional, default='0') - The TTL for the cookie (0 means session cookie)
   */
  withStickySession(cookieName='ISTIO-STICKY', cookiePath='/', cookieTtl='0')::
    v.string(cookieName, 'cookieName') +
    v.string(cookiePath, 'cookiePath') +
    v.string(cookieTtl, 'cookieTtl') +
    {
      local name = self.application.metadata.name,
      objects+: [
        {
          apiVersion: 'networking.istio.io/v1',
          kind: 'DestinationRule',
          metadata: {
            name: 'istio-sticky-' + name,
          },
          spec: {
            host: name,
            trafficPolicy: {
              loadBalancer: {
                consistentHash: {
                  httpCookie: {
                    name: cookieName,
                    path: cookiePath,
                    ttl: cookieTtl,
                  },
                },
              },
            },
          },
        },
      ],
    },
}
