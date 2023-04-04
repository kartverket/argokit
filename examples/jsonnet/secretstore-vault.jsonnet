local argokit = import '../../jsonnet/argokit.libsonnet';

[
  // Set up the vault secret store
  argokit.VaultSecretStore('foo-project'),

  // Fetch a secret's content and write to a kubernetes
  // secret on the key "DB_PASSWORD"
  argokit.VaultSecret('dbpass') {
    secrets: [{
      fromSecret: 'db-pass',
      toKey: 'DB_PASSWORD',
    }],
  },

  // Fetch a structured JSON object from a and map
  // keys and values to the kubernetes secret
  argokit.VaultSecret('allkeys') {
    allKeysFrom: [{
      fromSecret: 'allkeys',
    }],
  },
]
