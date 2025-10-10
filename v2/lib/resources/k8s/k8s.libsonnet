local configMap = import './configMap.libsonnet';
local rolebinding = import './rolebinding.libsonnet';

{
  configMap: configMap,
  rolebinding: rolebinding,
}
