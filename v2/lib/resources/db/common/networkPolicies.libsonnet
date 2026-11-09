{
  new(p, clusterName, env): {
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
              { port: 8000, protocol: 'TCP' },
              { port: 9090, protocol: 'TCP' },
              { port: 5432, protocol: 'TCP' },
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
              { port: 9090, protocol: 'TCP' },
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
              { port: 'metrics', protocol: 'TCP' },
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
              { protocol: 'TCP', port: 5432 },
              { protocol: 'TCP', port: 8000 },
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
              { protocol: 'TCP', port: 5432 },
              { protocol: 'TCP', port: 8000 },
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
                    'kubernetes.io/metadata.name': p.gatewayNS,
                  },
                },
                podSelector: {
                  matchLabels: {
                    'gateway.networking.k8s.io/gateway-name': env.gatewayName,
                  },
                },
              },
            ],
            ports: [
              { protocol: 'TCP', port: 5432 },
            ],
          },
        ],
      },
    },
    networkPolicyAmbientMesh: {
      apiVersion: 'networking.k8s.io/v1',
      kind: 'NetworkPolicy',
      metadata: {
        name: 'accept-ambient-traffic',
      },
      spec: {
        policyTypes: ['Ingress', 'Egress'],
        podSelector: {
          matchLabels: {
            'cnpg.io/cluster': clusterName,
          },
        },
        ingress: [
          {
            ports: [
              { protocol: 'TCP', port: 15008 },
            ],
          },
        ],
        egress: [
          {
            to: [
              {
                namespaceSelector: {
                  matchLabels: {
                    'kubernetes.io/metadata.name': 'istio-system',
                  },
                },
                podSelector: {
                  matchLabels: {
                    app: 'ztunnel',
                  },
                },
              },
              {
                podSelector: {
                  matchLabels: {
                    'cnpg.io/cluster': clusterName,
                  },
                },
              },
            ],
            ports: [
              { protocol: 'TCP', port: 15008 },
            ],
          },
        ],
      },
    },
    networkPolicyAllowEgressToKubeApi: {
      apiVersion: 'networking.k8s.io/v1',
      kind: 'NetworkPolicy',
      metadata: {
        name: 'allow-egress-to-kube-api',
      },
      spec: {
        egress: [
          {
            ports: [
              { port: 6443, protocol: 'TCP' },
            ],
            to: [
              { ipBlock: { cidr: env.cidrBlockKubeApi[0] } },
              { ipBlock: { cidr: env.cidrBlockKubeApi[1] } },
              { ipBlock: { cidr: env.cidrBlockKubeApi[2] } },
            ],
          },
        ],
        podSelector: {},
        policyTypes: ['Egress'],
      },
    },
  },
}
