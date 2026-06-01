local appAndObjects = import '../lib/appAndObjects/appAndObjects.libsonnet';
local externalSecrets = import '../lib/resources/externalSecrets.libsonnet';
local skipjob = appAndObjects.skipjob;
local gsmSecret(name) =
  externalSecrets.secret.new(
    name=name,
    allKeysFrom=[
      {
        fromSecret: name,
      },
    ],
  );

{
  dbArchiveJob(
    instanceName,
    schedule,
    databaseIP,
    gcpS3CredentialsSecret,
    databaseName,
    archiveUser='postgres',
    serviceAccount='dummyaccount@iam.gserviceaccount.com',
    cloudsqlInstanceConnectionName,
    port=5432,
    S3Host='s3-rin.statkart.no',
    S3DestinationPath,
    fullDump=false,
  ):

    local secretPrefix = 'cloudsql-';
    local instanceSecretName = secretPrefix + instanceName + '-instance';
    local archiveUserSecretName = secretPrefix + instanceName + '-' + archiveUser;


    skipjob.new(instanceName, 'ghcr.io/kartverket/database-arkiv:7b6dbf1f6542d6359d3929afac3bccfa28d37097')
    + skipjob.withCommand([
      '/entrypoint.sh',
    ])
    + skipjob.withCron(
      schedule=schedule,
      suspend=false,
      startingDeadlineSeconds=10,
    )
    + skipjob.withGcpServiceAccount(serviceAccount)
    + skipjob.withEnvironmentVariable('PGDATABASE', databaseName)
    + skipjob.withEnvironmentVariable('PGUSER', archiveUser)
    + skipjob.withEnvironmentVariableFromSecret('PGPASSWORD', archiveUserSecretName, 'password')
    + skipjob.withEnvironmentVariableFromSecret('AWS_ACCESS_KEY_ID', gcpS3CredentialsSecret, 'AWS_ACCESS_KEY_ID')
    + skipjob.withEnvironmentVariableFromSecret('AWS_SECRET_ACCESS_KEY', gcpS3CredentialsSecret, 'AWS_SECRET_ACCESS_KEY')
    + skipjob.withEnvironmentVariable('PGSSLCA', '/app/db-certs/server/cert')
    + skipjob.withEnvironmentVariable('PGSSLKEY', '/app/db-certs/client/private_key')
    + skipjob.withEnvironmentVariable('PGSSLCERT', '/app/db-certs/client/cert')
    + skipjob.withEnvironmentVariable('CLOUDSQL_INSTANCE_CONNECTION_NAME', cloudsqlInstanceConnectionName)
    + skipjob.withEnvironmentVariable('PGHOST', databaseIP)
    + skipjob.withEnvironmentVariable('PGPORT', std.toString(port))
    + skipjob.withEnvironmentVariable('S3_DESTINATION_PATH', S3DestinationPath)
    + skipjob.withEnvironmentVariable('S3_ENDPOINT_URL', 'https://' + S3Host)
    + skipjob.withEnvironmentVariable('PG_DUMP_ROLES', if fullDump then 'true' else 'false')
    + {
      application+: {
        spec+: {
          accessPolicy+: {
            outbound+: {
              external+: [
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
          filesFrom+: [
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
        },
      },
    }
    + skipjob.withObjects([
      gsmSecret(instanceSecretName),
      gsmSecret(archiveUserSecretName),
      gsmSecret(gcpS3CredentialsSecret),
    ]),
}
