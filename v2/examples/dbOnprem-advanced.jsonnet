local argokit = import '../../v2/jsonnet/argokit.libsonnet';

argokit.db.dbOnprem.new({
  databaseName: 'eksempel-advanced',
  environment: 'dbdev',
  instances: 2,
  // To allow Kubernetes-access to namespace for DBA's, set this to `true`. Needed for superuser access to databases.
  dbaAccess: false,
  storageSizeGi: 2,
  // imageExtensions wires the full object on the Cluster and activates it by name in the Database.
  // Direct image overrides and image-volume paths remain Cluster-only fields.
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
  imageExtensions: [
    {
      name: 'postgis',
      env: [
        {
          name: 'GDAL_DATA',
          value: '${image_root}/share/gdal',
        },
        {
          name: 'PROJ_DATA',
          value: '${image_root}/share/proj',
        },
      ],
      image: {
        reference: 'ghcr.io/kartverket/nrl-postgis-extension-test:3.6.2-18-trixie',
      },
      ld_library_path: ['system'],
    },
  ],
})
