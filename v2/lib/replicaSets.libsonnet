{
  withReplicaSets(initial, max='', targetCpuUtilization=80, targetMemoryUtilization=''): {
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
