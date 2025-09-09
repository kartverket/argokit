local util = import 'util.libsonnet';

{
  local rules(appname, namespace) = {
    rules+: [
      {
        application: appname,
        [if namespace != '' then 'namespace']: namespace,
      },
    ],
  },

  local ports(portname, port, protocol) = {
    ports: [
      {
        name: portname,
        protocol: protocol,
        port: port,
      },
    ],
  },

  new (parent):: {
    kindOfParent: parent.kind,

    withOutboundPostgres(host, ip):: {
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

    withOutboundOracle(host, ip):: {
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

    withOutboundSsh(host, ip):: {
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

    withOutboundLdaps(host, ip):: {
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

    withOutboundHttp(host, portname='', port=443, protocol='')::
      local kindOfParent = self.kindOfParent;
      {
        local httpPolicy (portname, port, protocol) = {
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
        spec+: if util.isSKIPJob(kindOfParent) then { container+: httpPolicy(portname, port, protocol) } else httpPolicy(portname, port, protocol)
      },

    withOutboundSkipApp(appname, namespace='')::
      local kindOfParent = self.kindOfParent;
      {
        local policy (appname, namespace) = {
          accessPolicy+: {
            outbound+: {
            } + rules(appname, namespace),
          },
        },
        spec+: if util.isSKIPJob(kindOfParent) then { container+: policy(appname, namespace) } else policy(appname, namespace)
      },

    withInboundSkipApp(appname, namespace=''):: {
      spec+: {
        accessPolicy+: {
          inbound+: {
          } + rules(appname, namespace),
        },
      },
    },
  },
}
