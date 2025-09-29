{
  /**
   *   - When conf.isSkipJob is true, it normalizes the structure of spec.
   *   - Extracts istioSettings, cron, job, and prometheus from spec (if present)
   *     and lifts them to top-level spec fields.
   *   - Keeps empty placeholders for these fields inside spec.container to preserve structure.
   *   - Prunes null/empty fields after reshaping.
   */
  normalizeSkipJob(conf)::
    if conf.isSkipJob then
      {
        local s = super.spec,
        local is = std.get(s, 'istioSettings', default=null, inc_hidden=true),
        local cr = std.get(s, 'cron', default=null, inc_hidden=true),
        local j = std.get(s, 'job', default=null, inc_hidden=true),
        local pr = std.get(s, 'prometheus', default=null, inc_hidden=true),

        spec: std.prune({
          container+: s {
            istioSettings:: {},
            cron:: {},
            job:: {},
            prometheus:: {},
          },
          istioSettings: is,
          cron: cr,
          job: j,
          prometheus: pr,
        }),
      }
    else {},

  /**
   * Hook: wrapAsApplicationAndObjects
   *   - When conf.isAppAndObjects is true, it copies the evaluated spec into application.spec.
   *   - Ensures the Application CR contains the same configuration as the root spec.
   */
  wrapAsApplicationAndObjects(conf)::
    if conf.isAppAndObjects
    then {
      local s = super.spec,
      application+: { spec+: s },
    }
    else {},
}
