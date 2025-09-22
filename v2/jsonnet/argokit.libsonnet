local accessPolicies = import '../lib/accessPolicies.libsonnet';
local environment = import '../lib/environment.libsonnet';
local ingress = import '../lib/ingress.libsonnet';
local replicas = import '../lib/replicas.libsonnet';
local probes = import '../lib/probes.libsonnet';

{
  application: {
                 new (name): {
                   apiVersion: 'skiperator.kartverket.no/v1alpha1',
                   kind: 'Application',
                   metadata: {
                     name: name,
                   },
                 },
               }
               + ingress
               + replicas
               + environment
               + accessPolicies
               + probes,

  skipJob: {
             new (name): {
               apiVersion: 'skiperator.kartverket.no/v1alpha1',
               kind: 'SKIPJob',
               metadata: {
                 name: name,
               },
             },
           }
           + accessPolicies
           + environment
           + probes
}
