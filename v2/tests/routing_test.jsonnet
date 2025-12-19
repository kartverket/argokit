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
};


local actual =
  argokit.routing.new('myapp-routing', 'myhostname', redirectToHTTPS=true)
  + argokit.routing.withRoute(pathPrefix='/web', targetApp='myapp-web', rewriteUri=false)
  + argokit.routing.withRoute(pathPrefix='/api', targetApp='myapp-api', rewriteUri=false, port=8080);

test.new(std.thisFile)
+ test.case.new(
  name='Setup routing spec',
  test=test.expect.eqDiff(
    actual=actual.spec,
    expected=expected.spec
  ),
)
+ test.case.new(
  name='Routing has correct kind and apiVersion',
  test=test.expect.eqDiff(
    actual={ kind: actual.kind, apiVersion: actual.apiVersion },
    expected={ kind: expected.kind, apiVersion: expected.apiVersion }
  ),
)
+ test.case.new(
  name='Routing has correct name',
  test=test.expect.eq(
    actual=actual.metadata.name,
    expected=expected.metadata.name
  ),
)
+ test.case.new(
  name='Routing has v2 flavor label',
  test=test.expect.eq(
    actual=actual.metadata.labels['skip.kartverket.no/argokit-flavor'],
    expected='v2'
  ),
)
+ test.case.new(
  name='Routing has git-ref label',
  test=test.expect.eq(
    actual=std.objectHas(actual.metadata.labels, 'skip.kartverket.no/argokit-git-ref'),
    expected=true
  ),
)
+ test.case.new(
  name='Routing has tag label',
  test=test.expect.eq(
    actual=std.objectHas(actual.metadata.labels, 'skip.kartverket.no/argokit-tag'),
    expected=true
  ),
)
+ test.case.new(
  name='Routing does not have deprecated label by default',
  test=test.expect.eq(
    actual=std.objectHas(actual.metadata.labels, 'skip.kartverket.no/argokit-deprecated-version'),
    expected=false
  ),
)
