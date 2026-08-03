local v = import '../../internal/validation.libsonnet';

{
  /**
  Mounts an existing secret as files at the specified path.
  Parameters:
    - secretName: string - The name of the secret to mount.
    - mountPath: string - The path to the mount.
    - defaultMode: number (optional) - Unix file permission bits for mounted files, e.g. 384 (0600 octal).
    - subPath: string (optional) - The sub-path inside the volume to mount.
  */
  withSecretAsMount(secretName, mountPath, defaultMode=null, subPath=null)::
    v.string(secretName, 'secretName') +
    v.string(mountPath, 'mountPath') +
    v.optionalNumber(defaultMode, 'defaultMode') +
    v.optionalString(subPath, 'subPath') +
    {
      application+: {
        spec+: {
          filesFrom+: [
            std.prune({
              mountPath: mountPath,
              secret: secretName,
              defaultMode: defaultMode,
              subPath: subPath,
            }),
          ],
        },
      },
    },

  /**
  Mounts a Persistent Volume Claim (PVC) to the specified path.
  Parameters:
    - pvcName: string - The name of the Persistent Volume Claim (PVC) to mount.
    - mountPath: string - The path to the mount.
    - subPath: string (optional) - The sub-path inside the volume to mount.
  */
  withPersistentVolumeClaimAsMount(pvcName, mountPath, subPath=null)::
    v.string(pvcName, 'pvcName') +
    v.string(mountPath, 'mountPath') +
    v.optionalString(subPath, 'subPath') +
    {
      application+: {
        spec+: {
          filesFrom+: [
            std.prune({
              mountPath: mountPath,
              persistentVolumeClaim: pvcName,
              subPath: subPath,
            }),
          ],
        },
      },
    },

  local validateEmptyDirName(emptyDir) =
    if std.length(emptyDir) == 0 then
      error 'emptyDir name cannot be an empty string'
    else if emptyDir == 'tmp' then
      error 'emptyDir name cannot be "tmp" as it is a reserved name'
    else emptyDir,

  /**
  Mounts an emptyDir volume at the specified path.
  Parameters:
    - mountPath: string - The path to the mount.
    - emptyDir: string - Name of the volume
    - subPath: string (optional) - The sub-path inside the volume to mount.
  */
  withEmptyDirAsMount(mountPath, emptyDir, subPath=null)::
    v.string(mountPath, 'mountPath') +
    v.string(emptyDir, 'emptyDir') +
    v.optionalString(subPath, 'subPath') +
    {
      application+: {
        spec+: {
          filesFrom+: [
            std.prune({
              mountPath: mountPath,
              emptyDir: validateEmptyDirName(emptyDir),
              subPath: subPath,
            }),
          ],
        },
      },
    },
}
