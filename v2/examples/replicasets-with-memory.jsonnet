local argokit = import '../jsonnet/argokit.libsonnet';

argokit.application.new('testapp')
+ argokit.replicas.withReplicas(initial=3, max=8, targetMemoryUtilization=50)
