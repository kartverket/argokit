local hooks = import './configHooks.libsonnet';

{
  AppAndObjects:: {
    apiVersion: 'v1',
    kind: 'List',

    local isSkipJob = self.application.kind == 'SKIPJob',

    local appConfig = {
      isSkipJob: isSkipJob,
      isAppAndObjects: true,
    },

    local result = std.foldl(
      function(ap, hook) ap + hook(appConfig),
      [hooks.normalizeSkipJob, hooks.wrapAsApplicationAndObjects],
      self
    ),

    items: std.sort([result.application] + result.objects, keyF=function(x) x.metadata.name),
    spec:: {},
  },
}
