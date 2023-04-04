local argokit = import '../../jsonnet/argokit.libsonnet';

[
  // Set up the gsm secret store
  argokit.GSMSecretStore('foo-project'),

  // Fetch a secret's content and write to a kubernetes
  // secret on the key "DB_PASSWORD"
  argokit.GSMSecret('dbpass') {
    secrets: [{
      fromSecret: 'db-pass',
      toKey: 'DB_PASSWORD',
    }],
  },

  // Fetch a structured JSON object from a and map
  // keys and values to the kubernetes secret
  argokit.GSMSecret('allkeys') {
    allKeysFrom: [{
      fromSecret: 'allkeys',
    }],
  },
]
