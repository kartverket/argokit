local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;
test.new(std.thisFile)
+ test.case.new(
  name='Postgres',
  test=test.expect.eqDiff(
    actual=(application.withOutboundPostgres('database.kartverket.no', '192.168.1.9')).application.spec,
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
  name='HTTP for SKIPApp',
  test=test.expect.eqDiff(
    actual=(application.withOutboundHttp('server.kartverket.no', port=444, portname='https', protocol='TCP')).application.spec,
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
