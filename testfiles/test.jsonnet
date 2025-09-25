local argokit = import '../v2/jsonnet/argokit.libsonnet';

// testing app with a simple non-AppAndObjects definition
local simpleApp = {
  apiVersion: 'skiperator.kartverket.no/v1alpha1',
  kind: 'Application',
  metadata: {
    name: 'test-app',
  },
  spec: {
    env: 'prod',
  },
};

argokit.application.newStandard('testapp')
+ argokit.application.withOutboundPostgres('host', 'ip')
