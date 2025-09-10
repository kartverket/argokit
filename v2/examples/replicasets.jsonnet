local argokit = import '../jsonnet/argokit.libsonnet';

argokit.application.new('testapp')
+ argokit.replicaSets.withReplicaSets(min=3, max=6, targetCpuUtilization=50)
