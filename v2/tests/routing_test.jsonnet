local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

test.new(std.thisFile)
+ test.case.new(
  name='Setup routing',
  test=test.expect.eqDiff(
    actual=(argokit.routing.new(name='myapp-routing',
                                hostname='myhostname',
                                routes=[
                                  argokit.routing.route(pathPrefix='/web', targetApp='myapp-web', rewriteUri=false),
                                  argokit.routing.route(pathPrefix='/api', targetApp='myapp-api', rewriteUri=false, port=8080),
                                ],
                                redirectToHTTPS=false)),
    expected={

      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'Routing',
      metadata: {
        name: 'myapp-routing',
      },
      spec: {
        hostname: 'myhostname',
        redirectToHTTPS: false,
        routes: [
          {
            pathPrefix: '/web',
            rewriteUri: false,
            targetApp: 'myapp-web',
          },
          {
            pathPrefix: '/api',
            rewriteUri: false,
            targetApp: 'myapp-api',
            port: 8080
          },
        ],
      },
    }

  ),
)
