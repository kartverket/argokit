local argokit = import '../jsonnet/argokit.libsonnet';

local serviceConfig = {
  PORT: 3000,
  TIMEOUT: 100,
};

[
  argokit.k8s.configMap.new(
    name='regular-configmap',
    data=serviceConfig,
  ),

  argokit.k8s.configMap.new(
    name='hashed-configmap',
    data=serviceConfig,
    hashed=true,
  ),
]
