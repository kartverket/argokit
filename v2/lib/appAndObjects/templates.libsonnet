local hooks = import './configHooks.libsonnet';
local internalUtils = import '../../internal/utils.libsonnet';

{
  AppAndObjects:: {
    apiVersion: 'v1',
    kind: 'List',

    items: std.sort([self.application + internalUtils.withArgokitVersionLabel(flavor='v2')] + self.objects, keyF=function(x) x.metadata.name),
  },
}
