local v = import '../internal/validation.libsonnet';
{
  local validateScrapeInterval(interval) =
    if interval == '' then {}
    else if !std.endsWith(interval, 's') && !std.endsWith(interval, 'm') then
      error 'scrapeInterval must end with "s" (seconds) or "m" (minutes)'
    else {},

  /**
   * Configure Prometheus metrics scraping for the application. After configuring an endpoint that exposes metrics, the platform itself will collect the metrics on the application's behalf.
   * 
   * Variables:
   *  - path: string - The path where metrics are exposed (e.g., '/metrics' or '/actuator/prometheus')
   *  - port: int - The port number where metrics are exposed
   *  - allowAllMetrics: bool (optional, default=false) - If true, all exposed metrics are scraped. 
   *                                                       Otherwise, a predefined list of metrics will be dropped.
   * See DefaultMetricDropList here: https://github.com/kartverket/skiperator/blob/main/pkg/util/constants.go#L19-L23
   *  - scrapeInterval: string (optional, default='60s') - ScrapeInterval specifies the interval at which Prometheus should scrape the metrics.
   */
  withPrometheus(path, port, allowAllMetrics=false, scrapeInterval='60s')::
    v.string(path, 'path') +
    v.number(port, 'port') +
    v.boolean(allowAllMetrics, 'allowAllMetrics') +
    v.string(scrapeInterval, 'scrapeInterval', allowEmpty=true) +
    validateScrapeInterval(scrapeInterval) +
    {
      application+: {
        spec+: {
          prometheus: std.prune({
            path: path,
            port: port,
            [if allowAllMetrics then 'allowAllMetrics']: allowAllMetrics,
            [if scrapeInterval != '' then 'scrapeInterval']: scrapeInterval,
          }),
        },
      },
    },
}
