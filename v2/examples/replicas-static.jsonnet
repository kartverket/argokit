local argokit = import '../jsonnet/argokit.libsonnet';

argokit.application.new('testapp')
+ argokit.replicas.withReplicas(4)
