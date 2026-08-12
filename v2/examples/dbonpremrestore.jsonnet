local argokit = import '../../v2/jsonnet/argokit.libsonnet';
argokit.db.dbOnpremrestoretest.new({
  databaseName: 'eksempel',
  environment: 'dev',
  instances: 2,
  storageSizeGi: 2,

// When restoring a postgresql cluster, You spin up a new cluster based on the backup
// databaseName is the name of your new cluster
// backupSourceClusterName is the name of your old cluster as defined in databaseName in the old clusters jsonnet


  // Old cluster name as stored in backup (databaseName).
  backupSourceClusterName: 'old-cluster-name',

  // Optional point-in-time restore. Set to null to recover to latest backup and PITR .
  // if using null, use it without any type of quotes
  recoveryTargetTime: '2026-06-10 12:00:00+00',
})
