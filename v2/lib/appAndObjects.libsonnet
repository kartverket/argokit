local configHooks = import '../lib/configHooks.libsonnet';

{
  AppAndObjects:: {
    apiVersion: 'v1',
    kind: 'List',
    testValue: 'b',
    local isSkipJob = self.application.kind == 'SKIPJob',

    items:
      local appConfig = {
        isSkipJob: isSkipJob,
        isAppAndObjects: true,
      };

      local result = std.foldl(
        function(ap, hook) ap + hook(appConfig),
        [configHooks.specHook],
        self
      );
      std.sort([result.application] + result.objects, keyF=function(x) x.metadata.name),
  },

  StandardApp:: {
    local app = self,
    local appConfig = {
      isSkipJob: app.kind == 'SKIPJob',
      isAppAndObjects: false,
    },
  },
}
