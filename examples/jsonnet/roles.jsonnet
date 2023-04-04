local argokit = import '../../jsonnet/argokit.libsonnet';

[
  // Gives the following users access to edit their namespace
  argokit.Roles {
    members: [
      'example1@kartverket.no',
      'example2@kartverket.no',
      'example3@kartverket.no',
    ],
  },
]
