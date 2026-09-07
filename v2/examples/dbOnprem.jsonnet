local argokit = import '../../v2/jsonnet/argokit.libsonnet';
argokit.db.dbOnprem.new({
  databaseName: 'eksempel',
  environment: 'dev',
  instances: 2,
  storageSizeGi: 2,
  // Database-side extensions are installed in the database.
  extensions: ['postgis'],
  // Cluster-side image extensions are resolved from the image catalog.
  // image.reference is meaningful only inside imageExtensions objects.
  imageExtensions: [
    'pgmq',
  ],
})
