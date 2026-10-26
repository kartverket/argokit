// To restore a postgresql backup, CNPG will spin up a new cluster and restore your backup in to it.
local argokit = import '../../../argokit/v2/jsonnet/argokit.libsonnet';

argokit.db.dbOnpremRestore.restore({
//Name of new database cluster you are creating, NOT the one you are trying to restore.
  databaseName: 'restore01',
//Environment the backed up cluster was deployed in, the new cluster will also be deployed here
  environment: 'dbdev',
  instances: 2,
  //StorageSize needs to be the same as the original or bigger
  storageSizeGi: 2,
  //Must define the gcpProject where the SecretStore was created. This is used to store the managed roles in GCP Secret Manager.
  gcpProject: 'dba-dev-b03a',
//Name of the database cluster you are trying to restore. The databaseName in the original deployment.
   backupSourceClusterName: 'flalar01'
})