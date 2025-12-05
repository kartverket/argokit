local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local utils = import '../internal/utils.libsonnet';

local expected = {
  apiVersion: 'skiperator.kartverket.no/v1alpha1',
  kind: 'Routing',
  metadata: {
    name: 'myapp-routing',
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
} + utils.withArgokitVersionLabel(false);


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
