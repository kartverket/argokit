local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

test.new(std.thisFile)
+ test.case.new(
  name='Postgres',
  test=test.expect.eqDiff(
    actual=(argokit.skipJob.new('a-job') + argokit.application.withOutboundPostgres('database.kartverket.no', '192.168.1.9')).spec,
    expected={
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
    }
  ),
)
+ test.case.new(
  name='HTTP for SKIPJob',
  test=test.expect.eqDiff(
    actual=(argokit.skipJob.new('a-job') + argokit.application.withOutboundHttp('server.kartverket.no', port=444, portname='https', protocol='TCP')).spec,
    expected={
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
    }
  ),
)
+ test.case.new(
  name='HTTP for SKIPApp',
  test=test.expect.eqDiff(
    actual=(argokit.application.new('an-app') + argokit.application.withOutboundHttp('server.kartverket.no', port=444, portname='https', protocol='TCP')).spec,
    expected={
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
    }
  ),
)
