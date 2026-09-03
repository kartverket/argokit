local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local dbOnprem = argokit.db.dbOnprem;

local findObject(objects, kind) = std.filter(function(obj) obj.kind == kind, objects)[0];

local clusterSpec(config) = findObject(dbOnprem.new(config).items, 'Cluster').spec;
local databaseSpec(config) = findObject(dbOnprem.new(config).items, 'Database').spec;

test.new(std.thisFile)
+ test.case.new(
  name='dbOnprem derives cluster extensions from extensions names',
  test=test.expect.eqDiff(
    actual={
      clusterExtensions: clusterSpec({
        databaseName: 'simple',
        extensions: [
          'plpgsql',
          'postgis',
        ],
        imageExtensions: [],
      }).postgresql.extensions,
      databaseExtensions: databaseSpec({
        databaseName: 'simple',
        extensions: [
          'plpgsql',
          'postgis',
        ],
        imageExtensions: [],
      }).extensions,
    },
    expected={
      clusterExtensions: [
        {
          name: 'plpgsql',
        },
        {
          name: 'postgis',
        },
      ],
      databaseExtensions: [
        {
          ensure: 'present',
          name: 'plpgsql',
        },
        {
          ensure: 'present',
          name: 'postgis',
        },
      ],
    },
  ),
)
+ test.case.new(
  name='dbOnprem preserves versioned database extensions and defaults catalog when needed',
  test=test.expect.eqDiff(
    actual={
      imageCatalogRef: clusterSpec({
        databaseName: 'catalog-default',
        extensions: [
          'plpgsql',
          {
            name: 'postgis',
          },
        ],
        imageExtensions: [],
      }).imageCatalogRef,
      databaseExtensions: databaseSpec({
        databaseName: 'catalog-default',
        extensions: [
          'plpgsql',
          {
            name: 'postgis',
          },
        ],
        imageExtensions: [],
      }).extensions,
    },
    expected={
      imageCatalogRef: {
        apiGroup: 'postgresql.cnpg.io',
        kind: 'ClusterImageCatalog',
        name: 'cnpg-psql-std',
        major: 18,
      },
      databaseExtensions: [
        {
          ensure: 'present',
          name: 'plpgsql',
        },
        {
          ensure: 'present',
          name: 'postgis',
        },
      ],
    },
  ),
)
+ test.case.new(
  name='dbOnprem advanced imageExtensions override derived cluster entries',
  test=test.expect.eqDiff(
    actual=clusterSpec({
      databaseName: 'advanced',
      extensions: [
        'plpgsql',
        'postgis',
      ],
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
          ld_library_path: ['standard'],
        },
      ],
    }).postgresql.extensions,
    expected=[
      {
        name: 'plpgsql',
      },
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
        ld_library_path: ['standard'],
      },
    ],
  ),
)
+ test.case.new(
  name='dbOnprem supports explicit imageCatalogRef override',
  test=test.expect.eqDiff(
    actual=clusterSpec({
      databaseName: 'catalog-override',
      imageCatalogRef: {
        apiGroup: 'postgresql.cnpg.io',
        kind: 'ImageCatalog',
        name: 'team-postgresql',
        major: 18,
      },
      extensions: [
        'plpgsql',
      ],
    }).imageCatalogRef,
    expected={
      apiGroup: 'postgresql.cnpg.io',
      kind: 'ImageCatalog',
      name: 'team-postgresql',
      major: 18,
    },
  ),
)
+ test.case.new(
  name='dbOnprem keeps direct image mode when advanced imageExtensions provide references',
  test=test.expect.eqDiff(
    actual={
      imageCatalogRef: if std.objectHas(clusterSpec({
        databaseName: 'direct-images',
        extensions: [],
        imageExtensions: [
          {
            name: 'postgis',
            image: {
              reference: 'ghcr.io/kartverket/nrl-postgis-extension-test:3.6.2-18-trixie',
            },
          },
        ],
      }), 'imageCatalogRef') then clusterSpec({
        databaseName: 'direct-images',
        extensions: [],
        imageExtensions: [
          {
            name: 'postgis',
            image: {
              reference: 'ghcr.io/kartverket/nrl-postgis-extension-test:3.6.2-18-trixie',
            },
          },
        ],
      }).imageCatalogRef else null,
      imageName: clusterSpec({
        databaseName: 'direct-images',
        extensions: [],
        imageExtensions: [
          {
            name: 'postgis',
            image: {
              reference: 'ghcr.io/kartverket/nrl-postgis-extension-test:3.6.2-18-trixie',
            },
          },
        ],
      }).imageName,
    },
    expected={
      imageCatalogRef: null,
      imageName: 'ghcr.io/cloudnative-pg/postgresql:18.4-standard-trixie',
    },
  ),
)
