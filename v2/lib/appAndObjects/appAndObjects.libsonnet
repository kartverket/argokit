local utils = import '../../internal/utils.libsonnet';
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
local utils = import './utils.libsonnet';

local azureAdApplication = import './azureAdApplication.libsonnet';
local externalSecrets = import './externalSecrets.libsonnet';
{
  application: {
                 new(name, image, port):
                   v.string(name, 'name') +
                   v.string(image, 'image') +
                   v.number(port, 'port') +
                   templates.AppAndObjects {
                     application:: {
                       apiVersion: 'skiperator.kartverket.no/v1alpha1',
                       kind: 'Application',
                       metadata: {
                         name: name,
                       },
                       spec+: std.prune({
                         image: image,
                         port: port,
                       },),
                     } + utils.withArgokitVersionAnnotation(),
                     objects:: [],
                   },
               }
               + ingress
               + replicas
               + environment
               + accessPolicies
               + probes
               + azureAdApplication
               + configMap
               + externalSecrets
               + utils,
}
