local argokit = import './argokit.libsonnet';
{
  dbArchiveJob(
    instanceName,
    schedule,
    databaseIP,
    gcpS3CredentialsSecret,
    databaseName,
    archiveUser='postgres',
    serviceAccount,
    cloudsqlInstanceConnectionName,
    port=5432,
    S3Host='s3-rin.statkart.no',
    S3DestinationPath,
    fullDump=false,
  ):
    local this = self;

    local instanceSecretName = instanceName + '-instance';
    local archiveUserSecretName = instanceName + '-' + archiveUser;
    [
      {
        apiVersion: 'skiperator.kartverket.no/v1alpha1',
        kind: 'SKIPJob',
        metadata: {
          name: instanceName,
        },
        spec: {
          cron: {
            schedule: schedule,
            suspend: false,
            startingDeadlineSeconds: 10,
          },
          container: {
            image: 'ghcr.io/kartverket/database-arkiv:8ddb5a4e119bf547bd320cdf0322426471bcc53e',
            command: [
              '/entrypoint.sh',
            ],
            accessPolicy: {
              outbound: {
                external: [
                  {
                    host: instanceName,
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
                value: archiveUser,
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
                    name: gcpS3CredentialsSecret,
                    key: 'AWS_ACCESS_KEY_ID',
                  },
                },
              },
              {
                name: 'AWS_SECRET_ACCESS_KEY',
                valueFrom: {
                  secretKeyRef: {
                    name: gcpS3CredentialsSecret,
                    key: 'AWS_SECRET_ACCESS_KEY',
                  },
                },
              },
              {
                name: 'PGSSLCA',
                value: '/app/db-certs/server/cert',
              },
              {
                name: 'PGSSLKEY',
                value: '/app/db-certs/client/private_key',
              },
              {
                name: 'PGSSLCERT',
                value: '/app/db-certs/client/cert',
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
                mountPath: '/app/db-certs/client',
                secret: archiveUserSecretName,
                defaultMode: 384,
              },
              {
                mountPath: '/app/db-certs/server',
                secret: instanceSecretName,
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
      argokit.GSMSecret(gcpS3CredentialsSecret) {
        allKeysFrom: [
          {
            fromSecret: gcpS3CredentialsSecret,
          },
        ],
      },
    ],
}
