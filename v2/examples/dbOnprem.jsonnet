local argokit = import '../../v2/jsonnet/argokit.libsonnet';
argokit.db.dbOnprem.new({
  databaseName: 'eksempel',
  environment: 'dev',
  instances: 2,
  storageSizeGi: 2,
  // imageExtensions wires image volumes on the Cluster and activates each extension in the Database.
  // Strings resolve from the image catalog; image.reference is supported in full objects.
  // For a full list of supported extension check docs at skip.kartverket.no
  imageExtensions: [
    'postgis',
    'wal2json',
  ],
})
