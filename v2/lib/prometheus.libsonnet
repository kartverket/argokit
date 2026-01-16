local v = import '../internal/validation.libsonnet';
{
  /**
   * Configure Prometheus metrics scraping for the application.
   * 
   * Variables:
   *  - path: string - The path where metrics are exposed (e.g., '/metrics' or '/actuator/prometheus')
   *  - port: int - The port number where metrics are exposed
   *  - allowAllMetrics: bool (optional, default=false) - If true, all exposed metrics are scraped. 
   *                                                       Otherwise, a predefined list of metrics will be dropped.
   */
  withPrometheus(path, port, allowAllMetrics=false)::
    v.string(path, 'path') +
    v.number(port, 'port') +
    (if allowAllMetrics != false then v.boolean(allowAllMetrics, 'allowAllMetrics') else {}) +
    {
      application+: {
        spec+: {
          prometheus: std.prune({
            path: path,
            port: port,
            [if allowAllMetrics then 'allowAllMetrics']: allowAllMetrics,
          }),
        },
      },
    },
}
