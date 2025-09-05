local argokit = import '../../../argokit/jsonnet/argokit.libsonnet';

argokit.Application('testapp')
+ argokit.ReplicaSets.replicaSets(min=3, max=6, targetCpuUtilization=50)
