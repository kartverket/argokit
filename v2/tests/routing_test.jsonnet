local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

local expected = {
  apiVersion: 'skiperator.kartverket.no/v1alpha1',
  kind: 'Routing',
  metadata: {
    name: 'myapp-routing',
    labels: {
      'skip.kartverket.no/argokit-git-ref': '58ac182fa0f09a1fd7e0997d519207d1b80fc61c',
      'skip.kartverket.no/argokit-tag': 'dev-dirty',
      'skip.kartverket.no/argokit-flavor': 'v2',
    },
  },
  spec: {
    hostname: 'myhostname',
    redirectToHTTPS: true,
    routes: [
      {
        pathPrefix: '/web',
        rewriteUri: false,
        targetApp: 'myapp-web',
      },
      {
        pathPrefix: '/api',
        port: 8080,
        rewriteUri: false,
        targetApp: 'myapp-api',
      },
    ],
  },
};


local actual =
  argokit.routing.new('myapp-routing', 'myhostname', redirectToHTTPS=true)
  + argokit.routing.withRoute(pathPrefix='/web', targetApp='myapp-web', rewriteUri=false)
  + argokit.routing.withRoute(pathPrefix='/api', targetApp='myapp-api', rewriteUri=false, port=8080);

test.new(std.thisFile)
+ test.case.new(
  name='Setup routing',
  test=test.expect.eqDiff(
    actual=actual,
    expected=expected
  ),
)
