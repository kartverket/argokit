local v = import '../../internal/validation.libsonnet';
local argokit = import '../../jsonnet/argokit.libsonnet';

{
  withConfigMapAsEnv(name, data, addHashToName=false):
    local cm = argokit.k8s.configMap.new(name, data, addHashToName);
    {
      application+: {
        spec+: {
          envFrom+: [
            { configMap: cm.metadata.name },
          ],
        },
      },
      objects+:: [cm],
    },

  withConfigMapAsMount(name, mountPath, data, addHashToName=false):
    v.string(mountPath, 'mountPath') +
    {
      local cm = argokit.k8s.configMap.new(name, data, addHashToName),
      application+: {
        spec+: {
          filesFrom+: [
            { configMap: cm.metadata.name, mountPath: mountPath },
          ],
        },
      },
      objects+:: [cm],
    },
}
