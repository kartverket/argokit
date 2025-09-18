local environment = import '../lib/environment.libsonnet';
local accessPolicies = import '../lib/accessPolicies.libsonnet';
local replicas = import '../lib/replicas.libsonnet';
local ingress = import '../lib/ingress.libsonnet';
local probes = import '../lib/probes.libsonnet';

{
  accessPolicies: accessPolicies,
  environment: environment,
  replicas: replicas,
  ingress: ingress,
  application: {
    new (name): {
      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'Application',
      metadata: {
        name: name,
      },
    }
  } + probes,

  skipJob: {
    new(name): {
      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'SKIPJob',
      metadata: {
        name: name,
      },
    },
  } + probes
}
