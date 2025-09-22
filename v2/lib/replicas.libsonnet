{

  /**
  Setup for replicas
  You can set static replicas
  You can set a min and max, if so number of replicas will increase if cpu usage is more than targetCpuUtilization (default 80%) or memory usage
  is more than targetMemoryUtilization (optional).

  Variables:
   - initial: int  - initial replicas (2 is recommended)
   - max: int (optional) - max number of replicas
   - targetCpuUtilization: int (optional) - maximum cpu utilization before increasing current replicas
   - targetMemoryUtilization: int (optional) - maximum memory utilization before increasing current replicas
  */
  withReplicas(initial, max='', targetCpuUtilization=80, targetMemoryUtilization=''): {
    spec+:
      if max != '' && initial != max then
        {
          replicas: {
            min: initial,
            max: max,
            targetCpuUtilization: targetCpuUtilization,
            [if targetMemoryUtilization != '' then 'targetMemoryUtilization']: targetMemoryUtilization,
          },
        }
      else
        {
          replicas: initial,
        },
  },
}
