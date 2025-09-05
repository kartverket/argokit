local argokit = import '../../../argokit/jsonnet/argokit.libsonnet';

argokit.Application('testapp')
+ argokit.ReplicaSets.replicaSets(min=3, targetMemoryUtilization=50)
