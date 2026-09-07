local argokit = import '../../v2/jsonnet/argokit.libsonnet';

argokit.db.dbOnprem.new({
  databaseName: 'eksempel-advanced',
  environment: 'dev',
  instances: 2,
  storageSizeGi: 2,
  // Database-side extension configuration is independent from imageExtensions.
  extensions: [
    {
      name: 'postgis',
      version: '3.6.2',
    },
  ],
  // Direct image overrides belong only to Cluster-side imageExtensions.
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
