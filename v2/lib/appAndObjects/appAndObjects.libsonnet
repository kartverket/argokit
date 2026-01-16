local internalUtils = import '../../internal/utils.libsonnet';
local v = import '../../internal/validation.libsonnet';
local accessPolicies = import '../accessPolicies.libsonnet';
local appAndObjects = import '../appAndObjects.libsonnet';
local environment = import '../environment.libsonnet';
local ingress = import '../ingress.libsonnet';
local probes = import '../probes.libsonnet';
local prometheus = import '../prometheus.libsonnet';
local replicas = import '../replicas.libsonnet';
local routing = import '../routing.libsonnet';
local configMap = import './configMap.libsonnet';
local templates = import './templates.libsonnet';
local utils = import './utils.libsonnet';
local resources = import '../specResources.libsonnet';
local azureAdApplication = import './azureAdApplication.libsonnet';
local externalSecrets = import './externalSecrets.libsonnet';
local mounts = import './mounts.libsonnet';
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
        },
        objects:: [],
      },
  } + internalUtils.withArgokitVersionLabel(flavor='v2')
  + ingress
  + replicas
  + environment
  + accessPolicies
  + probes
  + prometheus
  + azureAdApplication
  + configMap
  + externalSecrets
  + mounts
  + utils
  + resources,
}
