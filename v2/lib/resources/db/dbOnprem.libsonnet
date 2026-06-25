{
  // Creates a full CNPG database setup from one config object.
  new(config={}):
    local rolebinding = import '../k8s/rolebinding.libsonnet';
    local defaults = {
      databaseName: 'eksempel',
      environment: 'atkv3-dev',

      instances: 1,
      enablePDB: false,
      imageName: 'ghcr.io/cloudnative-pg/postgis:18.3-3.6.2-system-trixie',
      storageSizeGi: 1,

      // Note: 'extensions' is fully replaced when overridden, not merged.
      // Specify the complete list of extensions you want when overriding this.
      extensions: [
        {
          ensure: 'present',
          name: 'plpgsql',
        },
        {
          ensure: 'present',
          name: 'postgis',
          version: '3.6.2',
        },
      ],

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

      gatewayName: 'dba-pg-internal',
      gatewayNamespace: 'istio-gateways',
      gatewaySectionName: 'pg',

      cnpgOperatorNamespace: 'dba-cnpg',
      metricsNamespace: 'grafana-alloy',
      metricsAppInstance: 'alloy',
      metricsAppName: 'alloy',

      postgresqlParameters: {
        max_connections: '200',
        log_statement: 'ddl',
        log_line_prefix: '%t [%p] %h ',
        'auto_explain.log_min_duration': '20s',
      },
    };
    local p = defaults + config + {
      postgresqlParameters: defaults.postgresqlParameters + (if 'postgresqlParameters' in config then config.postgresqlParameters else {}),
    };
    // Input validation
    assert std.length(p.databaseName) > 0 : 'DatabaseName must not be empty';
    assert std.member(['atkv3-sandbox', 'atkv3-dev'], p.environment) : 'Environment must be either "atkv3-sandbox" or "atkv3-dev"'; // In the future there will be dedicated stateful/DB clusters
    assert p.instances >= 1 && p.instances <= 3 : 'Instances must be between 1 and 3'; // Two instances is enough for HA setup, three can make sense for load balancing and read scaling.
    assert p.storageSizeGi >= 1 : 'StorageSize must be minimum 1Gi';
    assert std.isBoolean(p.enablePDB) : 'enablePDB must be set and a boolean';

    local clusterName = '%s-cluster' % p.databaseName;
    local certSecretName =
      if p.certificateSecretName == null then clusterName else p.certificateSecretName;
    local writeHost = '%s-write.pg.%s.kartverket-intern.cloud' % [p.databaseName, p.environment];
    local readHost = '%s-read.pg.%s.kartverket-intern.cloud' % [p.databaseName, p.environment];

    local headlessServices = {
      ['%s-%d-hs' % [clusterName, instanceNumber]]: {
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
          name: '%s-%d-hs' % [clusterName, instanceNumber],
        },
        spec: {
          selector: {
            'cnpg.io/instanceName': '%s-%d' % [clusterName, instanceNumber],
          },
          clusterIP: 'None',
          ports: [
            {
              name: 'status',
              port: 8000,
              targetPort: 8000,
            },
            {
              name: 'postgres',
              port: 5432,
              targetPort: 5432,
            },
          ],
        },
      }
      for instanceNumber in std.range(1, p.instances)
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
      certificate: {
        apiVersion: 'cert-manager.io/v1',
        kind: 'Certificate',
        metadata: {
          name: clusterName,
        },
        spec: {
          secretName: certSecretName,
          issuerRef: {
            group: 'cert-manager.io',
            kind: 'ClusterIssuer',
            name: p.tlsIssuerName,
          },
          dnsNames: [writeHost, readHost],
          privateKey: {
            rotationPolicy: 'Always',
          },
        },
      },
      secretStore: {
        apiVersion: 'external-secrets.io/v1',
        kind: 'SecretStore',
        metadata: {
          name: 'gsm',
        },
        spec: {
          provider: {
            gcpsm: {
              projectID: 'dba-dev-b03a',
            },
          },
        },
      },
      serviceEntryS3: {
        apiVersion: 'networking.istio.io/v1',
        kind: 'ServiceEntry',
        metadata: {
          name: 's3-scality-barman',
        },
        spec: {
          exportTo: ['.'],
          hosts: ['s3-rin.statkart.no'],
          ports: [
            {
              number: 443,
              name: 'https',
              protocol: 'HTTPS',
            },
          ],
          resolution: 'DNS',
        },
      },
      externalSecret: {
        apiVersion: 'external-secrets.io/v1',
        kind: 'ExternalSecret',
        metadata: {
          name: 's3-scality-barman',
        },
        spec: {
          secretStoreRef: {
            kind: 'SecretStore',
            name: 'gsm',
          },
          data: [
            {
              secretKey: 'ACCESS_KEY_ID',
              remoteRef: {
                key: 'AWS_ACCESS_KEY_ID',
                metadataPolicy: 'None',
              },
            },
            {
              secretKey: 'ACCESS_SECRET_KEY',
              remoteRef: {
                key: 'AWS_SECRET_ACCESS_KEY',
                metadataPolicy: 'None',
              },
            },
          ],
        refreshInterval: '1h',
        target: {
          name: 's3-bucket-creds',
        },
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
          bootstrap: {
            initdb: {
              database: p.databaseName,
              owner: p.databaseName,
            },
          },
          enablePDB: if p.instances > 1 then p.enablePDB else false, // PDB doesn't make sense for single instance clusters
          imageName: p.imageName,
          storage: {
            size: p.storageSizeGi + 'Gi',
          },
          certificates: {
            serverCASecret: p.caSecretName,
            serverTLSSecret: certSecretName,
          },
          postgresql: {
            parameters: p.postgresqlParameters,
          },
        } + (if std.length(p.plugins) > 0 then {
          plugins: p.plugins,
      } else {}),
      },
      database: {
        apiVersion: 'postgresql.cnpg.io/v1',
        kind: 'Database',
        metadata: {
          name: p.databaseName,
        },
        spec: {
          cluster: {
            name: clusterName,
          },
          name: p.databaseName,
          owner: p.databaseName,
          extensions: p.extensions,
        },
      },
      objectStore: {
        apiVersion: 'barmancloud.cnpg.io/v1',
        kind: 'ObjectStore',
        metadata: {
          name: 's3-store',
        },
        spec: {
          instanceSidecarConfiguration: {
            env: [
              {
                name: 'AWS_REQUEST_CHECKSUM_CALCULATION',
                value: 'when_required',
              },
              {
                name: 'AWS_RESPONSE_CHECKSUM_VALIDATION',
                value: 'when_supported',
              },
              {
                name: 'AWS_SKIP_MD5_VALIDATION',
                value: 'true',
              },
            ],
          },
          retentionPolicy: '7d',
          configuration: {
            destinationPath: 's3://dbabucket/%s' % p.databaseName,
            endpointURL: 'https://s3-rin.statkart.no',
            s3Credentials: {
              accessKeyId: {
                name: 's3-bucket-creds',
                key: 'ACCESS_KEY_ID',
              },
              secretAccessKey: {
                name: 's3-bucket-creds',
                key: 'ACCESS_SECRET_KEY',
              },
            },
            wal: {
              compression: 'gzip',
            },
          },
        },
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
      networkPolicyCnpgOperator: {
        apiVersion: 'networking.k8s.io/v1',
        kind: 'NetworkPolicy',
        metadata: {
          name: 'allow-dbs-to-receive-cnpg-operator-checks',
        },
        spec: {
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/component': 'database',
              'app.kubernetes.io/managed-by': 'cloudnative-pg',
            },
          },
          ingress: [
            {
              from: [
                {
                  namespaceSelector: {
                    matchLabels: {
                      'kubernetes.io/metadata.name': p.cnpgOperatorNamespace,
                    },
                  },
                  podSelector: {
                    matchLabels: {
                      'app.kubernetes.io/name': 'cloudnative-pg',
                    },
                  },
                },
              ],
              ports: [
                {
                  port: 8000,
                  protocol: 'TCP',
                },
                {
                  port: 9090,
                  protocol: 'TCP',
                },
                {
                  port: 5432,
                  protocol: 'TCP',
                },
              ],
            },
          ],
          policyTypes: ['Ingress'],
        },
      },
      networkPolicyBarman: {
        apiVersion: 'networking.k8s.io/v1',
        kind: 'NetworkPolicy',
        metadata: {
          name: 'allow-dbs-to-receive-barman-connections',
        },
        spec: {
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/component': 'database',
              'app.kubernetes.io/managed-by': 'cloudnative-pg',
            },
          },
          ingress: [
            {
              from: [
                {
                  namespaceSelector: {
                    matchLabels: {
                      'kubernetes.io/metadata.name': p.cnpgOperatorNamespace,
                    },
                  },
                  podSelector: {
                    matchLabels: {
                      'app.kubernetes.io/name': 'plugin-barman-cloud',
                    },
                  },
                },
              ],
              ports: [
                {
                  port: 9090,
                  protocol: 'TCP',
                },
              ],
            },
          ],
          policyTypes: ['Ingress'],
        },
      },      
      networkPolicyMetricsScraping: {
        apiVersion: 'networking.k8s.io/v1',
        kind: 'NetworkPolicy',
        metadata: {
          name: 'allow-metrics-scraping-to-dbs',
        },
        spec: {
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/component': 'database',
              'app.kubernetes.io/managed-by': 'cloudnative-pg',
            },
          },
          ingress: [
            {
              from: [
                {
                  namespaceSelector: {
                    matchLabels: {
                      'kubernetes.io/metadata.name': p.metricsNamespace,
                    },
                  },
                  podSelector: {
                    matchLabels: {
                      'app.kubernetes.io/instance': p.metricsAppInstance,
                      'app.kubernetes.io/name': p.metricsAppName,
                    },
                  },
                },
              ],
              ports: [
                {
                  port: 'metrics',
                  protocol: 'TCP',
                },
              ],
            },
          ],
          policyTypes: ['Ingress'],
        },
      },
      networkPolicyPeerConnectivity: {
        apiVersion: 'networking.k8s.io/v1',
        kind: 'NetworkPolicy',
        metadata: {
          name: 'allow-dbs-connectivity-to-peers',
        },
        spec: {
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/component': 'database',
              'app.kubernetes.io/managed-by': 'cloudnative-pg',
            },
          },
          policyTypes: ['Egress', 'Ingress'],
          ingress: [
            {
              from: [
                {
                  podSelector: {
                    matchLabels: {
                      'app.kubernetes.io/component': 'database',
                      'app.kubernetes.io/managed-by': 'cloudnative-pg',
                    },
                  },
                },
              ],
              ports: [
                {
                  protocol: 'TCP',
                  port: 5432,
                },
                {
                  protocol: 'TCP',
                  port: 8000,
                },
              ],
            },
          ],
          egress: [
            {
              to: [
                {
                  podSelector: {
                    matchLabels: {
                      'app.kubernetes.io/component': 'database',
                      'app.kubernetes.io/managed-by': 'cloudnative-pg',
                    },
                  },
                },
              ],
              ports: [
                {
                  protocol: 'TCP',
                  port: 5432,
                },
                {
                  protocol: 'TCP',
                  port: 8000,
                },
              ],
            },
          ],
        },
      },
      networkPolicyGateway: {
        apiVersion: 'networking.k8s.io/v1',
        kind: 'NetworkPolicy',
        metadata: {
          name: 'allow-istio-pg-gateway',
        },
        spec: {
          podSelector: {
            matchLabels: {
              'cnpg.io/cluster': clusterName,
            },
          },
          policyTypes: ['Ingress'],
          ingress: [
            {
              from: [
                {
                  namespaceSelector: {
                    matchLabels: {
                      'kubernetes.io/metadata.name': p.gatewayNamespace,
                    },
                  },
                  podSelector: {
                    matchLabels: {
                      'gateway.networking.k8s.io/gateway-name': p.gatewayName,
                    },
                  },
                },
              ],
              ports: [
                {
                  protocol: 'TCP',
                  port: 5432,
                },
              ],
            },
          ],
        },
      },
      tlsRouteWrite: {
        apiVersion: 'gateway.networking.k8s.io/v1',
        kind: 'TLSRoute',
        metadata: {
          name: clusterName + '-write',
        },
        spec: {
          parentRefs: [
            {
              group: 'gateway.networking.k8s.io',
              kind: 'Gateway',
              name: p.gatewayName,
              namespace: p.gatewayNamespace,
              sectionName: p.gatewaySectionName,
            },
          ],
          hostnames: [writeHost],
          rules: [
            {
              backendRefs: [
                {
                  group: '',
                  kind: 'Service',
                  name: clusterName + '-rw',
                  port: 5432,
                  weight: 1,
                },
              ],
            },
          ],
        },
      },
      tlsRouteRead: {
        apiVersion: 'gateway.networking.k8s.io/v1',
        kind: 'TLSRoute',
        metadata: {
          name: clusterName + '-read',
        },
        spec: {
          parentRefs: [
            {
              group: 'gateway.networking.k8s.io',
              kind: 'Gateway',
              name: p.gatewayName,
              namespace: p.gatewayNamespace,
              sectionName: p.gatewaySectionName,
            },
          ],
          hostnames: [readHost],
          rules: [
            {
              backendRefs: [
                {
                  group: '',
                  kind: 'Service',
                  name: clusterName + '-ro',
                  port: 5432,
                  weight: 1,
                },
              ],
            },
          ],
        },
      },
      dbaNamespaceAdmins:
        rolebinding.new()
        + rolebinding.withNamespaceAdminGroup('AAD-TF-TEAM-DBA@kartverket.no'),
    } + headlessServices;
    // Return all objects as a list
    std.objectValues(objects)
}
