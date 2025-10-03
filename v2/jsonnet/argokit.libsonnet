local v = import '../internal/validation.libsonnet';
local accessPolicies = import '../lib/accessPolicies.libsonnet';
local azureAdApplication = import '../lib/azureAdApplication.libsonnet';
local hooks = import '../lib/configHooks.libsonnet';
local environment = import '../lib/environment.libsonnet';
local ingress = import '../lib/ingress.libsonnet';
local probes = import '../lib/probes.libsonnet';
local replicas = import '../lib/replicas.libsonnet';

local appAndObjects = import '../lib/appAndObjects/appAndObjects.libsonnet';
local resources = import '../lib/resources/resources.libsonnet';
{
  appAndObjects: appAndObjects,
  application: {
                 new(name):
                   v.string(name, 'name') +
                   {
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
             new(name):
               v.string(name, 'name') +
               {
                 apiVersion: 'skiperator.kartverket.no/v1alpha1',
                 kind: 'SKIPJob',
                 metadata: {
                   name: name,
                 },
               },
             enableArgokit():
               hooks.normalizeSkipJob({ isSkipJob: true, isAppAndObjects: false }),

           }
           + accessPolicies
           + environment
           + probes,
} + resources
