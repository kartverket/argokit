local v = import '../internal/validation.libsonnet';
{
  local rules(appname, namespace) = 
  {
    rules+: [
      {
        application: appname,
        [if namespace != '' then 'namespace']: namespace,
      },
    ],
  },
  

  local ports(portname, port, protocol) = 
  v.string(portname, 'portname') +
  v.number(port, 'port') +
  v.string(protocol, 'protocol') +
  {
    ports: [
      {
        name: portname,
        protocol: protocol,
        port: port,
      },
    ],
  },

  /**
  Defines that this application should be able access a postgres instance at host and ip
  Variables:
   - host: string - the hostname of the postgres instance
   - ip: string - the ip address of the postgres instance
  */
  withOutboundPostgres(host, ip):: 
  v.string(host, 'host') +
  v.string(ip, 'ip') +
  {
    application+: {
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
  },

  /**
  Defines that this application should be able access a oracle instance at host and ip
  Variables:
   - host: string - the hostname of the oracle instance
   - ip: string - the ip address of the oracle instance
  */
  withOutboundOracle(host, ip):: 
  v.string(host, 'host') +
  v.string(ip, 'ip') +
  {
    application+: {
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
  },

  /**
  Defines that this application should be able access a ssh server at host and ip
  Variables:
   - host: string - the hostname of the ssh server
   - ip: string - the ip address of the ssh server
  */
  withOutboundSsh(host, ip):: 
  v.string(host, 'host') +
  v.string(ip, 'ip') +
  {
    application+: {
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
  },

  /**
  Defines that this application should be able access a secure ldap server at host and ip
  Variables:
   - host: string - the hostname of the ldaps server
   - ip: string - the ip address of the ldaps server
  */
  withOutboundLdaps(host, ip):: 
  v.string(host, 'host') +
  v.string(ip, 'ip') +
  {
    application+: {
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
  },

  /**
  Defines that this application should be able access a http server at a given hostname
  Variables:
   - host: string - the hostname of the ssh server
   - portname: string (optional) - the name of the port
   - port: int (default 443) - port of the server
   - protocol: string (optional) - the protocol of the connection
  */
  withOutboundHttp(host, portname='', port=443, protocol='')::
    v.string(host, 'host') +
    v.string(portname, 'portname', true) +
    v.number(port, 'port') +
    v.string(protocol, 'protocol', true) +
    {
      local httpPolicy(portname, port, protocol) = {
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
      application+: {
        spec+: httpPolicy(portname, port, protocol),
      },
    },

  /**
  Defines that this application should be able to send traffic to another app in this or a specified namespace
  Variables:
   - appname: string - the name of the application
   - namespace: string (optional) - the namespace of the application
  */
  withOutboundSkipApp(appname, namespace='')::
    v.string(appname, 'appname') +
    v.string(namespace, 'namespace', true) +
    {
      local policy(appname, namespace) = {
        accessPolicy+: {
          outbound+: {
          } + rules(appname, namespace),
        },
      },
      application+: {
        spec+: policy(appname, namespace),
      },
    },

  /**
    Defines that this application should availabe to another app in this or a specified namespace
    Variables:
     - appname: string - the name of the application
     - namespace: string (optional) - the namespace of the application
    */
  withInboundSkipApp(appname, namespace=''):: 
    v.string(appname, 'appname') +
    v.string(namespace, 'namespace', true) +
    {
    application+: {
      spec+: {
        accessPolicy+: {
          inbound+: {
          } + rules(appname, namespace),
        },
      },
    },
  },
}
