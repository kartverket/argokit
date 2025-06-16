local argokit = import "./argokit.libsonnet";
{
    dbArchiveJob(
        name,
        schedule,
        databaseIP,
        gcpDatabasePasswordSecret,
        gcpS3CredentialsSecret,
        databaseName,
        databaseUser='postgres',
        serviceAccount,
        cloudsqlInstanceConnectionName,
        port='5432',
        S3Host='s3-rin.statkart.no',
        S3DestinationPath,
    ):
    local this = self;
    local dbPasswordSecretName = name + '-db-password';
    local s3CredentialsSecretName = name + '-s3-credentials';
    [
        {
        apiVersion: 'skiperator.kartverket.no/v1alpha1',
        kind: 'SKIPJob',
        metadata: {
            name: name,
        },
        spec: {
            cron: {
            schedule: schedule,
            suspend: false,
            startingDeadlineSeconds: 10,
            },
            container: {
            image: 'ghcr.io/kartverket/database-arkiv:0965c18bcdabebcbfea020718cd50c007dee0860',
            command: [
                '/entrypoint.sh',
            ],
            accessPolicy: {
                outbound: {
                external: [
                    {
                    host: 'dba-arkiv-test',
                    ip: databaseIP,
                    ports: [
                        {
                        name: 'sql',
                        port: port,
                        protocol: 'TCP',
                        },
                    ],
                    },
                    {
                    host: S3Host,
                    ports: [
                        {
                        name: 'scality-s3',
                        port: 443,
                        protocol: 'HTTPS',
                        },
                    ],
                    },
                ],
                },
            },
            env: [
                {
                name: 'PGDATABASE',
                value: databaseName,
                },
                {
                name: 'PGUSER',
                value: databaseUser,
                },
                {
                name: 'PGPASSWORD',
                valueFrom: {
                    secretKeyRef: {
                    name: dbPasswordSecretName,
                    key: 'PGPASSWORD',
                    },
                },
                },
                {
                name: 'AWS_ACCESS_KEY_ID',
                valueFrom: {
                    secretKeyRef: {
                    name: s3CredentialsSecretName,
                    key: 'AWS_ACCESS_KEY_ID',
                    },
                },
                },
                {
                name: 'AWS_SECRET_ACCESS_KEY',
                valueFrom: {
                    secretKeyRef: {
                    name: s3CredentialsSecretName,
                    key: 'AWS_SECRET_ACCESS_KEY',
                    },
                },
                },
                {
                name: 'PGSSLCA',
                value: '/app/db-certs/server.crt',
                },
                {
                name: 'PGSSLKEY',
                value: '/app/db-certs/client.key',
                },
                {
                name: 'PGSSLCERT',
                value: '/app/db-certs/client.crt',
                },
                {
                name: 'CLOUDSQL_INSTANCE_CONNECTION_NAME',
                value: cloudsqlInstanceConnectionName,
                },
                {
                name: 'PGHOST',
                value: databaseIP,
                },
                {
                name: 'PGPORT',
                value: port,
                },
                {
                name: 'S3_DESTINATION_PATH',
                value: S3DestinationPath,
                },
                {
                name: 'S3_ENDPOINT_URL',
                value: S3Host,
                },
            ],
            filesFrom: [
                {
                mountPath: '/app/certs',
                secret: 'database-certs',
                defaultMode: 384,
                },
            ],
            gcp: {
                auth: {
                serviceAccount: serviceAccount,
                },
            },
            },
        },
        },
        // 2. The new ExternalSecret for the database password.
        argokit.GSMSecret(dbPasswordSecretName) {
        secrets: [
            {
            fromSecret: gcpDatabasePasswordSecret,
            toKey: 'PGPASSWORD',
            },
        ],
        },
        // 3. The new ExternalSecret for the S3 credentials.
        argokit.GSMSecret(s3CredentialsSecretName) {
        allKeysFrom: [
            {
            fromSecret: gcpS3CredentialsSecret,
            },
        ],
        },
    ],
}