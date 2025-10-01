local argokit = import '../jsonnet/argokit.libsonnet';
local secrets = [
  {
    fromSecret: 'test-fromSecret',
    toKey: 'test',
  },
];
local allKeysFrom = [
    {
        fromSecret: 'test-fromSecret'
    }
];

argokit.secrets.newExternalSecretStore('coolio-gcp-project')
