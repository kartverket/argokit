local environment = import '../lib/environment.libsonnet';
local accessPolicies = import '../lib/accessPolicies.libsonnet';
local ingress = import '../lib/ingress.libsonnet';

{
  accessPolicies: accessPolicies,
  environment: environment,
  ingress: ingress,
  application: {
    new (name): {
      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'Application',
      metadata: {
        name: name,
      },
    }
  },
  skipJob: {
    new(name): {
      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'SKIPJob',
      metadata: {
        name: name,
      },
    },
  }
}
