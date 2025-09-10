local argokit = import '../jsonnet/argokit.libsonnet';

argokit.application.new('testapp')
+ argokit.replicaSets.withReplicaSets(4)
