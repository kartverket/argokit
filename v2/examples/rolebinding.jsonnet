local argokit = import '../jsonnet/argokit.libsonnet';


[
  argokit.k8s.rolebinding.new()
  + argokit.k8s.rolebinding.withNamespaceAdminGroup('testgroup'),

  argokit.k8s.rolebinding.new()
  + argokit.k8s.rolebinding.withUsers([
    'example1@kartverket.no',
    'example2@kartverket.no',
    'example3@kartverket.no',
  ]),
]
