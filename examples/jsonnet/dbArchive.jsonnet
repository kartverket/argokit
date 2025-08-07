local argokit = import '../../../argokit/jsonnet/argokit.libsonnet';
local dbArchive = import '../../../argokit/jsonnet/dbArchive.libsonnet';

argokit.ManifestsFrom([
  // Create a database archive job
  [argokit.GSMSecretStore("<your-project-id>")],
  dbArchive.dbArchiveJob(
    instanceName='<instancename>', // Name of the cloudsql instance in GCP
    schedule='0 2 * * *',  // At 2:00 every day
    databaseIP='10.x.x.x', // Private IP of the database instance
    gcpS3CredentialsSecret='database-s3-access', # Name of secret in GCP with ACCESS_KEY and SECRET_KEY for S3
    databaseName='my-db', // Individual database name to archive
    archiveUser='readonly', # User with enough permissions to archive the database
    cloudsqlInstanceConnectionName='<project>:<region>:<instancename>', // Cloud SQL instance connection name
    S3DestinationPath='s3://testbackup/arkivjobb-test', // S3 bucket and path where the archive will be stored
  ),
])
