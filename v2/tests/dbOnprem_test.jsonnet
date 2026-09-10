local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local dbOnprem = argokit.db.dbOnprem;

local findObject(objects, kind) = std.filter(function(obj) obj.kind == kind, objects)[0];

local clusterSpec(config) = findObject(dbOnprem.new(config).items, 'Cluster').spec;
local databaseSpec(config) = findObject(dbOnprem.new(config).items, 'Database').spec;

test.new(std.thisFile)
+ test.case.new(
  name='dbOnprem keeps database-only extensions out of cluster image extensions',
  test=test.expect.eqDiff(
    actual=local config = {
      databaseName: 'database-only',
      extensions: ['plpgsql'],
      imageExtensions: [],
    }; {
      clusterExtensions: if std.objectHas(clusterSpec(config).postgresql, 'extensions') then clusterSpec(config).postgresql.extensions else null,
      databaseExtensions: databaseSpec(config).extensions,
    },
    expected={
      clusterExtensions: null,
      databaseExtensions: [{ ensure: 'present', name: 'plpgsql' }],
    },
  ),
)
+ test.case.new(
  name='dbOnprem activates catalog-backed image extensions in the database',
  test=test.expect.eqDiff(
    actual=local config = {
      databaseName: 'catalog-backed',
      extensions: [{ name: 'plpgsql', ensure: 'absent', version: '1.0' }],
      imageExtensions: [
        'postgis',
        { name: 'pgmq', ensure: 'absent', version: '1.5.0' },
      ],
    }; {
      imageCatalogRef: clusterSpec(config).imageCatalogRef,
      clusterExtensions: clusterSpec(config).postgresql.extensions,
      databaseExtensions: databaseSpec(config).extensions,
    },
    expected={
      imageCatalogRef: {
        apiGroup: 'postgresql.cnpg.io',
        kind: 'ClusterImageCatalog',
        name: 'cnpg-psql-std',
        major: 18,
      },
      clusterExtensions: [
        { name: 'postgis' },
        { name: 'pgmq', ensure: 'absent', version: '1.5.0' },
      ],
      databaseExtensions: [
        { ensure: 'absent', name: 'plpgsql', version: '1.0' },
        { ensure: 'present', name: 'postgis' },
        { ensure: 'absent', name: 'pgmq', version: '1.5.0' },
      ],
    },
  ),
)
+ test.case.new(
  name='dbOnprem preserves direct image configuration only on the cluster',
  test=test.expect.eqDiff(
    actual=local config = {
      databaseName: 'direct-image',
      extensions: [],
      imageExtensions: [
        {
          name: 'postgis',
          ensure: 'present',
          version: '3.6.2',
          env: [
            { name: 'GDAL_DATA', value: '${image_root}/share/gdal' },
            { name: 'PROJ_DATA', value: '${image_root}/share/proj' },
          ],
          image: {
            reference: 'ghcr.io/kartverket/nrl-postgis-extension-test:3.6.2-18-trixie',
          },
          ld_library_path: ['system'],
          extension_control_path: ['share/extension'],
          dynamic_library_path: ['lib'],
          bin_path: ['bin'],
        },
      ],
    }; {
      imageCatalogRef: clusterSpec(config).imageCatalogRef,
      clusterExtensions: clusterSpec(config).postgresql.extensions,
      databaseExtensions: databaseSpec(config).extensions,
    },
    expected={
      imageCatalogRef: {
        apiGroup: 'postgresql.cnpg.io',
        kind: 'ClusterImageCatalog',
        name: 'cnpg-psql-std',
        major: 18,
      },
      clusterExtensions: [
        {
          name: 'postgis',
          ensure: 'present',
          version: '3.6.2',
          env: [
            { name: 'GDAL_DATA', value: '${image_root}/share/gdal' },
            { name: 'PROJ_DATA', value: '${image_root}/share/proj' },
          ],
          image: {
            reference: 'ghcr.io/kartverket/nrl-postgis-extension-test:3.6.2-18-trixie',
          },
          ld_library_path: ['system'],
          extension_control_path: ['share/extension'],
          dynamic_library_path: ['lib'],
          bin_path: ['bin'],
        },
      ],
      databaseExtensions: [
        { ensure: 'present', name: 'postgis', version: '3.6.2' },
      ],
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
      imageExtensions: ['postgis'],
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
  name='dbOnprem omits database extensions when none are configured',
  test=test.expect.eqDiff(
    actual=std.objectHas(databaseSpec({ databaseName: 'no-extensions' }), 'extensions'),
    expected=false,
  ),
)
