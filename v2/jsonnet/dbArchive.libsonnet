local appAndObjects = import '../lib/appAndObjects/appAndObjects.libsonnet';
local externalSecrets = import '../lib/resources/externalSecrets.libsonnet';
local skipjob = appAndObjects.skipjob;

{
  /**
  Creates a SKIPJob that dumps a Cloud SQL postgres database to S3-compatible storage on a cron schedule.
  Secrets for the database user, instance TLS certificates, and S3 credentials are fetched from Google
  Secret Manager and mounted automatically.
  Parameters:
    - instanceName: string - Cloud SQL instance name, used as the job name and the outbound access policy host.
    - schedule: string - cron expression for when the archive runs, e.g. '0 1 * * *'.
    - databaseIP: string - private IP of the Cloud SQL instance.
    - gcpS3CredentialsSecret: string - GSM secret name holding AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.
    - databaseName: string - name of the postgres database to dump.
    - archiveUser: string (optional) - postgres user to connect as. Defaults to 'postgres'.
    - serviceAccount: string - GCP service account email.
    - cloudsqlInstanceConnectionName: string - Cloud SQL connection name, e.g. project:region:instance.
    - port: number (optional) - postgres port. Defaults to 5432.
    - S3Host: string (optional) - S3-compatible endpoint hostname. Defaults to 's3-rin.statkart.no'.
    - S3DestinationPath: string - destination path including bucket, e.g. 's3://bucket/prefix'.
    - fullDump: boolean (optional) - include roles in the dump (pg_dumpall). Defaults to false.
  */
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

    local secretPrefix = 'cloudsql-';
    local instanceSecretName = secretPrefix + instanceName + '-instance';
    local archiveUserSecretName = secretPrefix + instanceName + '-' + archiveUser;

    skipjob.new(instanceName, 'ghcr.io/kartverket/database-arkiv:7b6dbf1f6542d6359d3929afac3bccfa28d37097')
    + skipjob.withCommand(['/entrypoint.sh'])
    + skipjob.withCron(schedule=schedule, startingDeadlineSeconds=10)
    + skipjob.withGcpServiceAccount(serviceAccount)
    + skipjob.withEnvironmentVariables({
      PGDATABASE: databaseName,
      PGUSER: archiveUser,
      PGSSLCA: '/app/db-certs/server/cert',
      PGSSLKEY: '/app/db-certs/client/private_key',
      PGSSLCERT: '/app/db-certs/client/cert',
      CLOUDSQL_INSTANCE_CONNECTION_NAME: cloudsqlInstanceConnectionName,
      PGHOST: databaseIP,
      PGPORT: std.toString(port),
      S3_DESTINATION_PATH: S3DestinationPath,
      S3_ENDPOINT_URL: 'https://' + S3Host,
      PG_DUMP_ROLES: if fullDump then 'true' else 'false',
    })
    + skipjob.withEnvironmentVariableFromSecret('PGPASSWORD', archiveUserSecretName, 'password')
    + skipjob.withEnvironmentVariableFromSecret('AWS_ACCESS_KEY_ID', gcpS3CredentialsSecret, 'AWS_ACCESS_KEY_ID')
    + skipjob.withEnvironmentVariableFromSecret('AWS_SECRET_ACCESS_KEY', gcpS3CredentialsSecret, 'AWS_SECRET_ACCESS_KEY')
    + skipjob.withOutboundPostgres(instanceName, databaseIP, port)
    + skipjob.withOutboundHttp(S3Host, portname='scality-s3', port=443, protocol='HTTPS')
    + skipjob.withSecretAsMount(archiveUserSecretName, '/app/db-certs/client', defaultMode=384)
    + skipjob.withSecretAsMount(instanceSecretName, '/app/db-certs/server', defaultMode=384)
    + skipjob.withObjects([
      externalSecrets.secret.new(name=instanceSecretName, allKeysFrom=[{ fromSecret: instanceSecretName }]),
      externalSecrets.secret.new(name=archiveUserSecretName, allKeysFrom=[{ fromSecret: archiveUserSecretName }]),
      externalSecrets.secret.new(name=gcpS3CredentialsSecret, allKeysFrom=[{ fromSecret: gcpS3CredentialsSecret }]),
    ]),
}
