local v = import '../internal/validation.libsonnet';
{
  /**
  Liveness probes define a resource that returns 200 OK when the app is running as intended.
  Returning a non-200 code will make kubernetes restart the app.
  	*/
  withLiveness(probe):: 
  v.object(probe, 'probe') +
  {
    application+: {
      spec+: { liveness: probe },
    },
  },

  /**
   Readiness probes define a resource that returns 200 OK when the app is running as intended. Kubernetes will wait
   until the resource returns 200 OK before 	marking the pod as Running and progressing with the deployment strategy.
   	*/
  withReadiness(probe):: 
  v.object(probe, 'probe') +
  {
    application+: {
      spec+: { readiness: probe },
    },
  },
  /**
  Kubernetes uses startup probes to know when a container application has started. If such a probe is configured, it
  disables liveness and readiness checks until it	 succeeds, making sure those probes don't interfere with the
  application startup. This can be used to adopt liveness checks on slow starting containers, avoiding them	getting
  killed by Kubernetes before they are up and running.
  */
  withStartup(probe):: 
  v.object(probe, 'probe') +
  {
    application+: {
      spec+: { startup: probe },
    },
  },

  /**
  Defines a probe to be used with startup, readiness and liveness

  Variables:
   - path: string - the path to the resource
   - port: int - the port of the server
   - failureThreshold: int (optional, default=3) - the threshold before the service is failing
   - timeout: int (optional, default=1) - timeout of the resource
   - initialDelay: int (optional, default=0) - how long to wait after startup before starting probing
  */
  probe(path, port, failureThreshold=3, timeout=1, initialDelay=0):: 
  v.string(path, 'path') + 
  v.number(port, 'port') +
  v.number(failureThreshold, 'failureThreshold', true) +
  v.number(timeout, 'timeout', true) +
  v.number(initialDelay, 'initialDelay', true) +
  std.prune({
    path: path,
    port: port,
    failureThreshold: failureThreshold,
    timeout: timeout,
    initialDelay: initialDelay,
  }),
}
