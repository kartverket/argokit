local commonDefaults = {
  instances: 2,
  enablePDB: false,
  dbaAccess: false,
  resourceSize: 'S',
  storageSizeGi: 5,

  imageCatalogRef: null,
  defaultImageCatalogRef: {
    apiGroup: 'postgresql.cnpg.io',
    kind: 'ClusterImageCatalog',
    name: 'cnpg-psql-std',
    major: 18,
  },

  extensions: [],
  imageExtensions: [],

  postgresqlParameters: {
    max_connections: '100',
    log_statement: 'ddl',
    log_line_prefix: '%t [%p] %h ',
    'auto_explain.log_min_duration': '20s',
    wal_keep_size: '2048MB',
    min_wal_size: '1GB',
    max_wal_size: '4GB',
    wal_compression: 'lz4',
    io_method: 'worker',
    effective_io_concurrency: '16',
    io_min_workers: '2',
    io_max_workers: '8',
    jit: 'off',
    work_mem: '6MB',
    huge_pages: 'try',
  },
};

local resolve(config, workloadDefaults) =
  local defaults = commonDefaults + workloadDefaults + {
    postgresqlParameters: commonDefaults.postgresqlParameters
      + (if std.objectHas(workloadDefaults, 'postgresqlParameters')
         then workloadDefaults.postgresqlParameters else {}),
  };
  local environment =
    if std.objectHas(config, 'environment')
    then config.environment
    else defaults.environment;

  defaults + config + {
    dbaAccess:
      if std.objectHas(config, 'dbaAccess')
      then config.dbaAccess
      else environment == 'sandbox',
    postgresqlParameters: defaults.postgresqlParameters
      + (if std.objectHas(config, 'postgresqlParameters')
         then config.postgresqlParameters else {}),
  };

{
  commonDefaults: commonDefaults,
  resolve: resolve,
}
