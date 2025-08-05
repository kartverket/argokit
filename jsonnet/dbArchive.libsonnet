local argokit = import './argokit.libsonnet';
{
  dbArchiveJob(
    name,
    schedule,
    databaseIP,
    gsmSecretPrefix,
    gcpS3CredentialsSecret,
    databaseName,
    databaseUser='postgres',
    serviceAccount,
    cloudsqlInstanceConnectionName,
    port=5432,
    S3Host='s3-rin.statkart.no',
    S3DestinationPath,
    fullDump=false,
  ):
    local this = self;

    local instanceSecretName = name + '-instance';
    local archiveUserSecretName = name + '-' + databaseUser;
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
            image: 'ghcr.io/kartverket/database-arkiv:0c620907a48005e5588bd0a120060a1627e48eb2',
            command: [
              '/entrypoint.sh',
            ],
            accessPolicy: {
              outbound: {
                external: [
                  {
                    host: gsmSecretPrefix,
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
                    name: archiveUserSecretName,
                    key: 'password',
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
                value: std.toString(port),
              },
              {
                name: 'S3_DESTINATION_PATH',
                value: S3DestinationPath,
              },
              {
                name: 'S3_ENDPOINT_URL',
                value: 'https://' + S3Host,
              },
              {
                name: 'PG_DUMP_ROLES',
                value: if fullDump then 'true' else 'false',
              },
            ],
            filesFrom: [
              {
                mountPath: '/app/db-certs',
                secret: archiveUserSecretName,
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
      argokit.GSMSecret(instanceSecretName) {
        allKeysFrom: [
          {
            fromSecret: instanceSecretName,
          },
        ],
      },
      argokit.GSMSecret(archiveUserSecretName) {
        allKeysFrom: [
          {
            fromSecret: archiveUserSecretName,
          },
        ],
      },
      argokit.GSMSecret(s3CredentialsSecretName) {
        allKeysFrom: [
          {
            fromSecret: gcpS3CredentialsSecret,
          },
        ],
      },
    ],
}
