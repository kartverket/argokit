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
}
