local skip = import '../skip.libsonnet';
local frontendVersion = importstr './frontend-version';
local backendVersion = importstr './frontend-version';

local BaseApp = {
    spec: {
        port: 8080
    }
};

[
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