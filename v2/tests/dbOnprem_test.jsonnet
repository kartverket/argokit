local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local dbOnprem = argokit.db.dbOnprem;

local findObject(objects, kind) = std.filter(function(obj) obj.kind == kind, objects)[0];

local clusterSpec(config) = findObject(dbOnprem.new(config).items, 'Cluster').spec;
local databaseSpec(config) = findObject(dbOnprem.new(config).items, 'Database').spec;

test.new(std.thisFile)
+ test.case.new(
  name='dbOnprem keeps database extensions independent from cluster image extensions',
  test=test.expect.eqDiff(
    actual={
      clusterExtensions: if std.objectHas(clusterSpec({
        databaseName: 'simple',
        extensions: ['plpgsql'],
        imageExtensions: [],
      }).postgresql, 'extensions') then clusterSpec({
        databaseName: 'simple',
        extensions: ['plpgsql'],
        imageExtensions: [],
      }).postgresql.extensions else null,
      databaseExtensions: databaseSpec({
        databaseName: 'simple',
        extensions: ['plpgsql'],
        imageExtensions: [],
      }).extensions,
    },
    expected={
      clusterExtensions: null,
      databaseExtensions: [
        {
          ensure: 'present',
          name: 'plpgsql',
        },
      ],
    },
  ),
)
+ test.case.new(
  name='dbOnprem renders catalog-backed image extensions independently',
  test=test.expect.eqDiff(
    actual={
      imageCatalogRef: clusterSpec({
        databaseName: 'catalog-default',
        extensions: [
          {
            name: 'postgis',
            version: '3.6.2',
          },
        ],
        imageExtensions: ['postgis'],
      }).imageCatalogRef,
      clusterExtensions: clusterSpec({
        databaseName: 'catalog-default',
        extensions: [
          {
            name: 'postgis',
            version: '3.6.2',
          },
        ],
        imageExtensions: ['postgis'],
      }).postgresql.extensions,
      databaseExtensions: databaseSpec({
        databaseName: 'catalog-default',
        extensions: [{ name: 'postgis', version: '3.6.2' }],
        imageExtensions: ['postgis'],
      }).extensions,
    },
    expected={
      imageCatalogRef: {
        apiGroup: 'postgresql.cnpg.io',
        kind: 'ClusterImageCatalog',
        name: 'cnpg-psql-std',
        major: 18,
      },
      clusterExtensions: [{ name: 'postgis' }],
      databaseExtensions: [{ ensure: 'present', name: 'postgis', version: '3.6.2' }],
    },
  ),
)
+ test.case.new(
  name='dbOnprem preserves explicit direct imageExtensions objects',
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
  name='dbOnprem ignores image references in database extensions',
  test=test.expect.eqDiff(
    actual={
      databaseExtensions: databaseSpec({
        databaseName: 'database-image-ignored',
        extensions: [
          {
            name: 'postgis',
            version: '3.6.2',
            image: { reference: 'ignored.example/postgis:3.6.2' },
          },
        ],
        imageExtensions: [],
      }).extensions,
      clusterFields: local spec = clusterSpec({
        databaseName: 'database-image-ignored',
        extensions: [
          {
            name: 'postgis',
            version: '3.6.2',
            image: { reference: 'ignored.example/postgis:3.6.2' },
          },
        ],
        imageExtensions: [],
      }); {
        imageCatalogRef: if std.objectHas(spec, 'imageCatalogRef') then spec.imageCatalogRef else null,
        imageName: if std.objectHas(spec, 'imageName') then spec.imageName else null,
        extensions: if std.objectHas(spec.postgresql, 'extensions') then spec.postgresql.extensions else null,
      },
    },
    expected={
      databaseExtensions: [
        {
          ensure: 'present',
          name: 'postgis',
          version: '3.6.2',
        },
      ],
      clusterFields: {
        imageCatalogRef: null,
        imageName: 'ghcr.io/cloudnative-pg/postgresql:18.4-standard-trixie',
        extensions: null,
      },
    },
  ),
)
+ test.case.new(
  name='dbOnprem keeps different database and image extension names separate',
  test=test.expect.eqDiff(
    actual={
      databaseExtensions: databaseSpec({
        databaseName: 'different-extension-names',
        extensions: ['postgis'],
        imageExtensions: ['pgmq'],
      }).extensions,
      clusterExtensions: clusterSpec({
        databaseName: 'different-extension-names',
        extensions: ['postgis'],
        imageExtensions: ['pgmq'],
      }).postgresql.extensions,
    },
    expected={
      databaseExtensions: [{ ensure: 'present', name: 'postgis' }],
      clusterExtensions: [{ name: 'pgmq' }],
    },
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
