local configHooks = import '../lib/configHooks.libsonnet';

{
  skipJobConfig(app, conf): {
    application: {
      spec+:
        if conf.isSkipJob then { container+: app.application.spec } else app.application.spec,
    },
  },
  AppAndObjects:: {
    apiVersion: 'v1',
    kind: 'List',
    items:
      local appConfig = {
        isSkipJob: true,
      };

      local result = std.foldl(
        function(ap, hook) ap + hook(ap, appConfig),
        configHooks,
        self
      );
      std.sort([result.application] + result.objects, keyF=function(x) x.metadata.name),
  },
}
