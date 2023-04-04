local skip = import '../../jsonnet/skip.libsonnet';
local frontendVersion = importstr './frontend-version';
local backendVersion = importstr './frontend-version';

local BaseApp = {
    spec: {
        port: 8080
    }
};

[
    skip.GSMSecretStore("foo-project"),
    skip.GSMSecret("dbpass") {
        secrets: [{
            fromSecret: "db-pass",
            toKey: "DB_PASSWORD",
        }]
    },
    skip.GSMSecret("allkeys") {
        allKeysFrom: [{
            fromSecret: "allkeys",
        }]
    },
    skip.Roles {
        members: [
            "foo@bar.com"
        ]
    },
    BaseApp + skip.Application("foo-frontend") {
        spec+: {
            image: frontendVersion
        }
    },
    BaseApp + skip.Application("foo-backend") {
        spec+: {
            image: backendVersion
        }
    }
]