local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

local jobPolicy = argokit.accessPolicies.new({ kind: 'SKIPJob' });
local appPolicy = argokit.accessPolicies.new({ kind: 'SKIPApp' });


test.new(std.thisFile)
+ test.case.new(
  name='Postgres',
  test=test.expect.eqDiff(
    actual=jobPolicy.withOutboundPostgres('database.kartverket.no', '192.168.1.9'),
    expected={
      spec: {
        accessPolicy: {
          outbound: {
            external: [
              {
                host: 'database.kartverket.no',
                ip: '192.168.1.9',
                ports: [
                  {
                    name: 'postgres-port',
                    port: 5432,
                    protocol: 'TCP',
                  },
                ],
              },
            ],
          },
        },
      },
    }
  ),
)
+ test.case.new(
  name='HTTP for SKIPJob',
  test=test.expect.eqDiff(
    actual=jobPolicy.withOutboundHttp('server.kartverket.no', port=444, portname='https', protocol='TCP'),
    expected={
      spec: {
        container: {
          accessPolicy: {
            outbound: {
              external: [
                {
                  host: 'server.kartverket.no',
                  ports: [
                    {
                      name: 'https',
                      port: 444,
                      protocol: 'TCP',
                    },
                  ],
                },
              ],
            },
          },
        },
      },
    }
  ),
)
+ test.case.new(
  name='HTTP for SKIPApp',
  test=test.expect.eqDiff(
    actual=appPolicy.withOutboundHttp('server.kartverket.no', port=444, portname='https', protocol='TCP'),
    expected={
      spec: {
        accessPolicy: {
          outbound: {
            external: [
              {
                host: 'server.kartverket.no',
                ports: [
                  {
                    name: 'https',
                    port: 444,
                    protocol: 'TCP',
                  },
                ],
              },
            ],
          },
        },
      },
    }
  ),
)
