local v = import '../../internal/validation.libsonnet';
local accessPolicies = import '../accessPolicies.libsonnet';
local appAndObjects = import '../appAndObjects.libsonnet';
local environment = import '../environment.libsonnet';
local ingress = import '../ingress.libsonnet';
local probes = import '../probes.libsonnet';
local replicas = import '../replicas.libsonnet';
local routing = import '../routing.libsonnet';
local hooks = import './configHooks.libsonnet';
local templates = import './templates.libsonnet';

local azureAdApplication = import './azureAdApplication.libsonnet';

{
  application: {
                 new(name):
                   v.string(name, 'name') +
                   templates.AppAndObjects {
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
               templates.AppAndObjects {
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
