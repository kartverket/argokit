local argokit = import '../../v2/jsonnet/argokit.libsonnet';
argokit.db.dbOnprem.new({
  databaseName: 'eksempel',
  environment: 'dev',
  instances: 2,
  storageSizeGi: 2,
})
