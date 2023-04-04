local argokit = import '../../jsonnet/argokit.libsonnet';
local frontendVersion = importstr './frontend-version';
local backendVersion = importstr './frontend-version';

local BaseApp = {
  spec: {
    port: 8080,
  },
};

[
  argokit.GSMSecretStore('foo-project'),
  argokit.GSMSecret('dbpass') {
    secrets: [{
      fromSecret: 'db-pass',
      toKey: 'DB_PASSWORD',
    }],
  },
  argokit.GSMSecret('allkeys') {
    allKeysFrom: [{
      fromSecret: 'allkeys',
    }],
  },
  argokit.Roles {
    members: [
      'foo@bar.com',
    ],
  },
  BaseApp + argokit.Application('foo-frontend') {
    spec+: {
      image: frontendVersion,
    },
  },
  BaseApp + argokit.Application('foo-backend') {
    spec+: {
      image: backendVersion,
    },
  },
]
