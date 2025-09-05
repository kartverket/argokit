{
  local rules(appname, namespace) = {
    rules+: [
      {
        application: appname,
        [if namespace != '' then 'namespace']: namespace,
      },
    ],
  },
  outbound: {
    local ports(portname, port, protocol) = {
      ports: [
        {
          name: portname,
          protocol: protocol,
          port: port,
        },
      ],
    },
    postgres(host, ip): {
      spec+: {
        accessPolicy+: {
          outbound+: {
            external+: [
              {
                host: host,
                ip: ip,
              } + ports('postgres-port', 5432, 'TCP'),
            ],
          },
        },
      },
    },
    oracle(host, ip): {
      spec+: {
        accessPolicy+: {
          outbound+: {
            external+: [
              {
                host: host,
                ip: ip,
              } + ports('oracle', 1521, 'TCP'),
            ],
          },
        },
      },
    },
    ssh(host, ip): {
      spec+: {
        accessPolicy+: {
          outbound+: {
            external+: [
              {
                host: host,
                ip: ip,
              } + ports('sftp', 22, 'TCP'),
            ],
          },
        },
      },
    },
    ldaps(host, ip): {
      spec+: {
        accessPolicy+: {
          outbound+: {
            external+: [
              {
                host: host,
                ip: ip,
              } + ports('ldaps', 636, 'TCP'),
            ],
          },
        },
      },
    },
    http(host, portname='', port=443, protocol=''): {
      spec+: {
        accessPolicy+: {
          outbound+: {
            external+: [
              {
                host: host,
              } + if port == 443 || port == 80 then {} else ports(portname, port, protocol),
            ],
          },
        },
      },
    },
    httpJob(host, portname='', port=443, protocol=''): {
      spec+: {
        container+: {
          accessPolicy+: {
            outbound+: {
              external+: [
                {
                  host: host,
                } + if port == 443 || port == 80 then {} else ports(portname, port, protocol),
              ],
            },
          },
        },
      },
    },
    skipApp(appname, namespace=''): {
      spec+: {
        accessPolicy+: {
          outbound+: {
          },
        },
      },
    },
    skipAppJob(appname, namespace=''): {
      spec+: {
        container+: {
          accessPolicy+: {
            outbound+: {
            } + rules(appname, namespace),
          },
        },
      },
    },
    skipAppByTeam(appname, team): {
      spec+: {
        accessPolicy+: {
          outbound+: {
            rules+: [
              {
                application: appname,
                namespacesByLabel: {
                  team: team,
                },
              },
            ],
          },
        },
      },
    },
    skipAppByTeamJob(appname, team): {
      spec+: {
        container+: {
          accessPolicy+: {
            outbound+: {
              rules+: [
                {
                  application: appname,
                  namespacesByLabel: {
                    team: team,
                  },
                },
              ],
            },
          },
        },
      },
    },
  },
  inbound: {
    skipApp(appname, namespace=''): {
      spec+: {
        accessPolicy+: {
          inbound+: {
          } + rules(appname, namespace),
        },
      },
    },
    skipAppByTeam(appname, team): {
      spec+: {
        accessPolicy+: {
          inbound+: {
            rules+: [
              {
                application: appname,
                namespacesByLabel: {
                  team: team,
                },
              },
            ],
          },
        },
      },
    },
  },
}
