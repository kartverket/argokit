local resourceSizes = import './common/resourceSizes.libsonnet';
local extensionsLib = import './common/extensions.libsonnet';
local environments = import './common/onpremEnvironments.libsonnet';
local connections = import './common/connectionResources.libsonnet';
local networkPolicies = import './common/networkPolicies.libsonnet';
local backupResources = import './common/backupResources.libsonnet';

{
  // Creates a full CNPG database setup from one config object.
  // This is only used for restore functionality testing, and not for production use.
  // We should add functionality for user to define what object store slash env to restore from
  restore(config={}):
    local rolebinding = import '../k8s/rolebinding.libsonnet';
    local defaults = {
      databaseName: 'eksempel',
      environment: 'dev',

      instances: 2,
      enablePDB: false,
      dbaAccess: false,
      resourceSize: 'S',
      storageSizeGi: 1,

      imageCatalogRef: null,
      defaultImageCatalogRef: {
        apiGroup: 'postgresql.cnpg.io',
        kind: 'ClusterImageCatalog',
        name: 'cnpg-psql-std',
        major: 18,
      },

      //Compatibility input for extensions present in the base image
      //
      extensions: [],
      //Extensions resolved from the ImageCatalog
      imageExtensions: [],

      plugins: [
        {
          name: 'barman-cloud.cloudnative-pg.io',
          enabled: true,
          isWALArchiver: true,
          parameters: {
            barmanObjectName: 's3-store',
          },
        },
      ],

      caSecretName: 'lets-encrypt-ca',
      certificateSecretName: null,
      tlsIssuerName: 'cluster-issuer',
      caCrt: |||
        -----BEGIN CERTIFICATE-----
        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
        -----END CERTIFICATE-----
      |||,

      gatewayNS: 'istio-gateways',
      cnpgOperatorNamespace: 'dba-cnpg',
      metricsNamespace: 'grafana-alloy',
      metricsAppInstance: 'alloy',
      metricsAppName: 'alloy',

      // Restore source cluster name from S3 backup (Barman serverName).
      backupSourceClusterName: null,
      // Optional point-in-time-recovery timestamp.
      recoveryTargetTime: null,

      postgresqlParameters: {
        max_connections: '200',
        log_statement: 'ddl',
        log_line_prefix: '%t [%p] %h ',
        'auto_explain.log_min_duration': '20s',
      },
    };

    local configuredEnvironment =
      if std.objectHas(config, 'environment')
      then config.environment
      else defaults.environment;
    local p = defaults + config + {
      dbaAccess: if std.objectHas(config, 'dbaAccess') then config.dbaAccess else configuredEnvironment == 'sandbox',
      postgresqlParameters: defaults.postgresqlParameters + (if 'postgresqlParameters' in config then config.postgresqlParameters else {}),
    };
    local extensionConfig = extensionsLib.resolve(p);
    local clusterExtensions = extensionConfig.clusterExtensions;
    local effectiveImageCatalogRef = extensionConfig.effectiveImageCatalogRef;

    // Input validation
    assert std.length(p.databaseName) > 0 : 'DatabaseName must not be empty';
    assert std.member(['sandbox', 'dev', 'dbdev'], p.environment) : 'Environment must be either "sandbox", "dev" or "dbdev"';  // In the future there will be dedicated stateful/DB clusters, dbdev is one of those
    assert p.instances >= 1 && p.instances <= 3 : 'Instances must be between 1 and 3';  // Two instances is enough for HA setup, three can make sense for load balancing and read scaling.
    assert p.storageSizeGi >= 1 : 'StorageSize must be minimum 1Gi';
    assert std.isBoolean(p.enablePDB) : 'enablePDB must be set and a boolean';
    assert std.type(p.backupSourceClusterName) == 'string' && std.length(p.backupSourceClusterName) > 0 : 'backupSourceClusterName must be a non-empty string';
    assert p.recoveryTargetTime == null || (std.type(p.recoveryTargetTime) == 'string' && std.length(p.recoveryTargetTime) > 0) : 'recoveryTargetTime must be null or a non-empty string';
    assert std.isBoolean(p.dbaAccess) :
           'dbaAccess must be set and a boolean';
    assert resourceSizes.get(p.resourceSize, 'restore') != null;

    local clusterName = '%s-cluster' % p.databaseName;
    local backupSourceClusterFullName = '%s-cluster' % p.backupSourceClusterName;

    local env = environments.get(p.environment);
    local k8sCluster = env.k8sCluster;
    local bucketName = env.bucketName;

    local certSecretName =
      if p.certificateSecretName == null then clusterName else p.certificateSecretName;
    local connectionEnv = env + {
      prettyUrl: 'pg.' + env.k8sCluster,
    };
    local connectionObjects =
      connections.new(p, clusterName, connectionEnv, certSecretName);
    local scheduledBackup = {
      apiVersion: 'postgresql.cnpg.io/v1',
      kind: 'ScheduledBackup',
      metadata: {
        name: clusterName,
      },
      spec: {
        cluster: {
          name: clusterName,
        },
        method: 'plugin',
        pluginConfiguration: {
          name: 'barman-cloud.cloudnative-pg.io',
        },
        schedule: '0 0 2 * * *', // Every day at 02:00
      },
    };
    local backupObjects = {
      serviceEntryS3: backupResources.serviceEntryS3,
      objectStore: backupResources.objectStore(bucketName, 's3-store', p.databaseName),
      restoreSourceObjectStore: backupResources.objectStore(
        bucketName,
        's3-store-restore-source',
        p.backupSourceClusterName
      ),
      scheduledBackup: scheduledBackup,
    };

    local objects = {
      caSecret: {
        apiVersion: 'v1',
        kind: 'Secret',
        metadata: {
          name: p.caSecretName,
        },
        type: 'Opaque',
        stringData: {
          'ca.crt': p.caCrt,
        },
      },
      cluster: {
        apiVersion: 'postgresql.cnpg.io/v1',
        kind: 'Cluster',
        metadata: {
          name: clusterName,
        },
        spec: {
          instances: p.instances,
          backup:{
            target: 'primary'
            },
          bootstrap: {
            recovery: {
              source: backupSourceClusterFullName,
            } + (if p.recoveryTargetTime != null then {
              recoveryTarget: {
                targetTime: p.recoveryTargetTime,
              },
            } else {}),
          },
          externalClusters: [
            {
              name: backupSourceClusterFullName,
              plugin: {
                name: 'barman-cloud.cloudnative-pg.io',
                parameters: {
                  barmanObjectName: 's3-store-restore-source',
                  serverName: backupSourceClusterFullName,
                },
              },
            },
          ],
          enablePDB: if p.instances > 1 then p.enablePDB else false,  // PDB doesn't make sense for single instance clusters
          [if effectiveImageCatalogRef == null then 'imageName']: p.imageName,
          storage: {
            size: p.storageSizeGi + 'Gi',
          },
          walStorage: {
            size: 2 + 'Gi',
          },
          certificates: {
            serverCASecret: p.caSecretName,
            serverTLSSecret: certSecretName,
          },
          postgresql: {
            parameters: p.postgresqlParameters,
            [if std.length(clusterExtensions) > 0 then 'extensions']: clusterExtensions,
          },
        } + (if std.length(p.plugins) > 0 then {
               plugins: p.plugins,
             } else {}),
      },
      podMonitor: {
        apiVersion: 'monitoring.coreos.com/v1',
        kind: 'PodMonitor',
        metadata: {
          name: clusterName,
        },
        spec: {
          selector: {
            matchLabels: {
              'cnpg.io/cluster': clusterName,
            },
          },
          podMetricsEndpoints: [
            {
              port: 'metrics',
            },
          ],
        },
      },
      [if p.dbaAccess then 'dbaNamespaceAdmins']:
        rolebinding.new()
        + rolebinding.withNamespaceAdminGroup('AAD-TF-TEAM-DBA@kartverket.no'),
    } + connectionObjects + backupObjects + networkPolicies.new(p, clusterName, env);
    
    // Return all objects as a list
    {
      apiVersion: 'v1',
      kind: 'List',
      items: std.objectValues(objects),
    },
}
