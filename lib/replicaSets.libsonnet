{
  replicaSets(min=2, max=5, targetCpuUtilization=80, targetMemoryUtilization=''): {
    spec+: {
      replicas: {
        min: min,
        max: max,
        targetCpuUtilization: targetCpuUtilization,
        [if targetMemoryUtilization != '' then 'targetMemoryUtilization']: targetMemoryUtilization
      }
    },
  },
  staticReplicaSets(static=1): {
    spec+: {
      replicas: static,
    },
  },
}
