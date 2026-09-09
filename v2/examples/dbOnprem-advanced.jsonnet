local argokit = import '../../v2/jsonnet/argokit.libsonnet';

argokit.db.dbOnprem.new({
  databaseName: 'eksempel-advanced',
  environment: 'dev',
  instances: 2,
  storageSizeGi: 2,
  // imageExtensions wires the full object on the Cluster and activates it by name in the Database.
  // Direct image overrides and image-volume paths remain Cluster-only fields.
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
