local environment = import '../lib/environment.libsonnet';
local accessPolicies = import '../lib/accessPolicies.libsonnet';

{
  accessPolicies: accessPolicies,
  environment: environment,
  Application(name): {
      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'Application',
      metadata: {
        name: name,
      },
    },
}
