local hooks = import './configHooks.libsonnet';

{
  AppAndObjects:: {
    apiVersion: 'v1',
    kind: 'List',

    items: std.sort([self.application] + self.objects, keyF=function(x) x.metadata.name),
  },
}
