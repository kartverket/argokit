local v = import '../../internal/validation.libsonnet';
local accessPolicies = import '../accessPolicies.libsonnet';
local appAndObjects = import '../appAndObjects.libsonnet';
local environment = import '../environment.libsonnet';
local ingress = import '../ingress.libsonnet';
local probes = import '../probes.libsonnet';
local replicas = import '../replicas.libsonnet';
local routing = import '../routing.libsonnet';
local azureAdApplication = import './azureAdApplication.libsonnet';
local configMap = import './configMap.libsonnet';
local templates = import './templates.libsonnet';

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
               + azureAdApplication
               + configMap,
}
