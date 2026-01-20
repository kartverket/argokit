local v = import '../../internal/validation.libsonnet';

{
  /**
  Mounts an existing secret as files at the specified path.
  Parameters:
    - secretName: string - The name of the secret to mount.
    - mountPath: string - The path to the mount.
  */
  withSecretAsMount(secretName, mountPath)::
    v.string(secretName, 'secretName') +
    v.string(mountPath, 'mountPath') +
    {
      application+: {
        spec+: {
          filesFrom+: [
            {
              mountPath: mountPath,
              secret: secretName,
            },
          ],
        },
      },
    },

  /**
  Mounts a Persistent Volume Claim (PVC) to the specified path.
  Parameters:
    - pvcName: string - The name of the Persistent Volume Claim (PVC) to mount.
    - mountPath: string - The path to the mount.
  */
  withPersistentVolumeClaimAsMount(pvcName, mountPath)::
    v.string(pvcName, 'pvcName') +
    v.string(mountPath, 'mountPath') +
    {
      application+: {
        spec+: {
          filesFrom+: [
            {
              mountPath: mountPath,
              persistentVolumeClaim: pvcName,
            },
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
  */
  withEmptyDirAsMount(mountPath, emptyDir)::
    v.string(mountPath, 'mountPath') +
    v.string(emptyDir, 'emptyDir') +
    {
      application+: {
        spec+: {
          filesFrom+: [
            {
              mountPath: mountPath,
              emptyDir: validateEmptyDirName(emptyDir),
            },
          ],
        },
      },
    },
}
