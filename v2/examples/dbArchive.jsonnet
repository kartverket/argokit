local argokit = import '../jsonnet/argokit.libsonnet';

argokit.dbArchiveJob(
  instanceName='pg-01',
  schedule='0 1 * * *',
  databaseIP='10.0.0.1',
  gcpS3CredentialsSecret='s3-credentials',
  databaseName='my-db',
  archiveUser='readonly',
  serviceAccount='archive-sa@project.iam.gserviceaccount.com',
  cloudsqlInstanceConnectionName='project:europe-north1:pg-01',
  S3DestinationPath='s3://testbackup/arkivjobb-test',
)
