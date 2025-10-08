local argokit = import '../jsonnet/argokit.libsonnet';


[
  argokit.rolebinding.new()
  + argokit.rolebinding.withNamespaceAdminGroup('testgroup'),

  argokit.rolebinding.new()
  + argokit.rolebinding.withUsers([
    'example1@kartverket.no',
    'example2@kartverket.no',
    'example3@kartverket.no',
  ]),
]
