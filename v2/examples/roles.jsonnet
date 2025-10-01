local argokit = import '../jsonnet/argokit.libsonnet';


[
  argokit.roles.newRoleBinding()
  + argokit.roles.withNamespaceAdminGroup('testgroup'),

  argokit.roles.newRoleBinding()
  + argokit.roles.withUsers([
    'example1@kartverket.no',
    'example2@kartverket.no',
    'example3@kartverket.no',
  ]),
]
