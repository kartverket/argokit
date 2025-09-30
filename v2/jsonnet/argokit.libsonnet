local v = import '../internal/validation.libsonnet';
local accessPolicies = import '../lib/accessPolicies.libsonnet';
local appAndObjects = import '../lib/appAndObjects.libsonnet';
local azureAdApplication = import '../lib/azureAdApplication.libsonnet';
local hooks = import '../lib/configHooks.libsonnet';
local environment = import '../lib/environment.libsonnet';
local ingress = import '../lib/ingress.libsonnet';
local probes = import '../lib/probes.libsonnet';
local replicas = import '../lib/replicas.libsonnet';
local routing = import '../lib/routing.libsonnet';
{
  routing: routing,
  application: {
                 new(name):
                   v.string(name, 'name') +
                   appAndObjects.AppAndObjects {
                     application:: {
                       apiVersion: 'skiperator.kartverket.no/v1alpha1',
                       kind: 'Application',
                       metadata: {
                         name: name,
                       },
                     },
                     objects:: [],
                   },
               }
               + ingress
               + replicas
               + environment
               + accessPolicies
               + probes
               + azureAdApplication,
  skipJob: {
             new(name):
               v.string(name, 'name') +
               appAndObjects.AppAndObjects {
                 application:: {
                   apiVersion: 'skiperator.kartverket.no/v1alpha1',
                   kind: 'SKIPJob',
                   metadata: {
                     name: name,
                   },
                 },
                 objects:: [],
               },
             enableArgokit():
               hooks.normalizeSkipJob({ isSkipJob: true, isAppAndObjects: false }),

           }
           + accessPolicies
           + environment
           + probes,
}
