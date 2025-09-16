local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

test.new(std.thisFile)
+ test.case.new(
  name='Setup routing',
  test=test.expect.eqDiff(
    actual=(argokit.routing.new('myapp-routing',
                                'myhostname',
                                [
                                  argokit.routing.route(pathPrefix='/web', targetApp='myapp-web', rewriteUri=false),
                                  argokit.routing.route(pathPrefix='/api', targetApp='myapp-api', rewriteUri=false),
                                ])),
    expected={

      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'Routing',
      metadata: {
        name: 'myapp-routing',
      },
      spec: {
        hostname: 'myhostname',
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
          },
        ],
      },
    }

  ),
)
