local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';


local object = {
  apiVersion: 'networking.istio.io/v1alpha3',
  kind: 'DestinationRule',
  metadata: {
    name: 'istio-sticky' + 'test',
  },
  spec: {
    host: 'test',
    trafficPolicy: {
      loadBalancer: {
        consistentHash: {
          httpCookie: {
            name: 'ISTIO-STICKY',
            path: '/',
            ttl: '0',
          },
        },
      },
    },
  },
};

local app =
  application.new('app', 'foo.io/image', 8080)
  + application.withAdditionalObjects(object);


local appB =
  application.new('app', 'foo.io/image', 8080)
  + application.withAdditionalObjects([
    {
      apiVersion: 'v1',
      kind: 'List',
      metadata: {
        name: 'x',
      },
    },
    {
      apiVersion: 'v1',
      kind: 'List',
      metadata: {
        name: 'y',
      },
    },
  ]);

local label = 'Test withAdditionalObjects ';

test.new(std.thisFile)
+ test.case.new(
  name=label + ' object is added to the objects list',
  test=test.expect.eqDiff(
    actual=app.items[1],
    expected=object
  )
)

+ test.case.new(
  name=label + ' object is added to the objects list',
  test=test.expect.eqDiff(
    actual=std.length(appB.items),
    expected=3
  )
)
