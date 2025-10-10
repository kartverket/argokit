local v = import '../../../internal/validation.libsonnet';

local hashConfigMap() = {
  local this = self,
  metadata+: {
    local hash = std.substr(std.md5(std.toString(this.data)), 0, 7),
    local orig_name = super.name,
    name: orig_name + '-' + hash,
    labels+: { name: orig_name },
  },
};

{
  new(name, data, addHashToName=false):
    v.string(name, 'name') +
    v.object(data, 'data') +
    v.boolean(addHashToName, 'addHashToName') +
    {
      apiVersion: 'v1',
      kind: 'ConfigMap',
      metadata: {
        name: name + '-configmap',
      },
      data: data,
    } + if addHashToName then hashConfigMap() else {},
}
