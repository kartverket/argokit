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

  withConfigMapAsMount(name, mountPath, data, addHashToName=false, defaultMode=null, subPath=null):
    v.optionalNumber(defaultMode, 'defaultMode') +
    v.optionalString(subPath, 'subPath') +
    v.string(mountPath, 'mountPath') +
    {
      local cm = argokit.k8s.configMap.new(name, data, addHashToName),
      application+: {
        spec+: {
          filesFrom+: [
            std.prune({
              configMap: cm.metadata.name,
              mountPath: mountPath,
              defaultMode: defaultMode,
              subPath: subPath,
            }),
          ],
        },
      },
      objects+:: [cm],
    },
}
