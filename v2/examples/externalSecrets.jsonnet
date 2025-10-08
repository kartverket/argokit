local argokit = import '../jsonnet/argokit.libsonnet';

local secrets = [
  {
    fromSecret: 'test-fromSecret',
    toKey: 'test',
  },
];
local allKeysFrom = [
  {
    fromSecret: 'test-fromSecret',
  },
];


[
  argokit.externalSecrets.store.new('coolio-gcp-project'),

  argokit.externalSecrets.secret.new(name='testsecrets', secrets=secrets),

  argokit.externalSecrets.secret.new(name='testsecrets-2', allKeysFrom=allKeysFrom),
]
