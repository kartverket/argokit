local argokit = import '../../../argokit/jsonnet/argokit.libsonnet';

argokit.Application('testapp')
+ argokit.ReplicaSets.staticReplicaSets(2)
