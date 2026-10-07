local argokit = import '../../v2/jsonnet/argokit.libsonnet';
argokit.db.dbOnprem.new({
  databaseName: 'eksempel',
  environment: 'dbdev',
  instances: 2,
  storageSizeGi: 2,
  // imageExtensions wires image volumes on the Cluster and activates each extension in the Database.
  // Strings resolve from the image catalog; image.reference is supported in full objects.
  // For a full list of supported extension check docs at skip.kartverket.no
  imageExtensions: [
    'postgis',
    'wal2json',
  ],
  //Must define the gcpProject where the SecretStore is created. This is used to store the managed roles in GCP Secret Manager.
  gcpProject: 'dev-gcp-project',
  //Definition of users that will be created in the database, its required to define atleast 1.
  users: {
    //Username for user1
    user1: {
      //Define if the user needs write access to the database
      isWriteUser: true,
    },
    user2: {
      isWriteUser: false,
    },
  },
})
