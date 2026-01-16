local v = import '../internal/validation.libsonnet';
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
  withReplicas(initial=2, max=null, targetCpuUtilization=null, targetMemoryUtilization=null): 
  v.number(initial, 'initial') +
  v.number(max, 'max', true) +
  v.number(targetCpuUtilization, 'targetCpuUtilization', true) +
  v.number(targetMemoryUtilization, 'targetMemoryUtilization', true) + 
  {
    application+: {
      spec+:
        if max != null && initial != max then
          {
            replicas: std.prune({
              min: initial,
              max: max,
              targetCpuUtilization: targetCpuUtilization,
              targetMemoryUtilization: targetMemoryUtilization
            }),
          }
        else
          {
            replicas: initial,
          },
    },
  },
}
