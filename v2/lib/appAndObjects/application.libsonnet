local internalUtils = import '../../internal/utils.libsonnet';
local v = import '../../internal/validation.libsonnet';
local accessPolicies = import '../accessPolicies.libsonnet';
local environment = import '../environment.libsonnet';
local gcp = import '../gcp.libsonnet';
local ingress = import '../ingress.libsonnet';
local probes = import '../probes.libsonnet';
local prometheus = import '../prometheus.libsonnet';
local replicas = import '../replicas.libsonnet';
local resources = import '../specResources.libsonnet';
local workload = import '../workload.libsonnet';
local azureAdApplication = import './azureAdApplication.libsonnet';
local configMap = import './configMap.libsonnet';
local externalSecrets = import './externalSecrets.libsonnet';
local mounts = import './mounts.libsonnet';
local templates = import './templates.libsonnet';
local utils = import './utils.libsonnet';

local optionalArray(value, label) =
  if value == null then {} else v.array(value, label, allowEmpty=true);

local optionalObject(value, label) =
  if value == null then {} else v.object(value, label, allowEmpty=true);

local portInAdditionalPorts(port, additionalPorts) =
  std.length([p for p in additionalPorts if std.objectHas(p, 'port') && p.port == port]) > 0;

local extraContainer(
  name,
  image,
  type='standard',
  command=null,
  args=null,
  env=null,
  envFrom=null,
  filesFrom=null,
  additionalPorts=[],
  resources=null,
  liveness=null,
  readiness=null,
  startup=null,
  ingressPort=null
) =
  v.string(name, 'name') +
  v.string(image, 'image') +
  v.enum(type, 'type', ['standard', 'init']) +
  optionalArray(command, 'command') +
  optionalArray(args, 'args') +
  optionalArray(env, 'env') +
  optionalArray(envFrom, 'envFrom') +
  optionalArray(filesFrom, 'filesFrom') +
  v.array(additionalPorts, 'additionalPorts', allowEmpty=true) +
  optionalObject(resources, 'resources') +
  optionalObject(liveness, 'liveness') +
  optionalObject(readiness, 'readiness') +
  optionalObject(startup, 'startup') +
  v.optionalNumber(ingressPort, 'ingressPort') +
  v.require(ingressPort == null || portInAdditionalPorts(ingressPort, additionalPorts), 'ingressPort must be declared in the container additionalPorts') +
  std.prune({
    name: name,
    image: image,
    type: type,
    command: command,
    args: args,
    env: env,
    envFrom: envFrom,
    filesFrom: filesFrom,
    additionalPorts: additionalPorts,
    resources: resources,
    liveness: liveness,
    readiness: readiness,
    startup: startup,
    ingressPort: ingressPort,
  });

{
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

  /**
  Builds a Skiperator Application extra container spec.
  Parameters:
    - name: string - container name, unique in the pod.
    - image: string - container image.
    - type: string - standard (default) or init. init creates a native sidecar init container.
    - ingressPort: number (optional) - route Application ingress traffic to this container port. Must be present in additionalPorts.
    - additionalPorts: array (optional) - ports exposed by this container.
    - env, envFrom, filesFrom, resources, liveness, readiness, startup: optional raw Skiperator container fields.
  */
  extraContainer(
    name,
    image,
    type='standard',
    command=null,
    args=null,
    env=null,
    envFrom=null,
    filesFrom=null,
    additionalPorts=[],
    resources=null,
    liveness=null,
    readiness=null,
    startup=null,
    ingressPort=null
  )::
    extraContainer(
      name=name,
      image=image,
      type=type,
      command=command,
      args=args,
      env=env,
      envFrom=envFrom,
      filesFrom=filesFrom,
      additionalPorts=additionalPorts,
      resources=resources,
      liveness=liveness,
      readiness=readiness,
      startup=startup,
      ingressPort=ingressPort,
    ),

  /**
  Adds one extra container to the Application pod.
  */
  withExtraContainer(
    name,
    image,
    type='standard',
    command=null,
    args=null,
    env=null,
    envFrom=null,
    filesFrom=null,
    additionalPorts=[],
    resources=null,
    liveness=null,
    readiness=null,
    startup=null,
    ingressPort=null
  )::
    {
      application+: {
        spec+: {
          extraContainers+: [
            extraContainer(
              name=name,
              image=image,
              type=type,
              command=command,
              args=args,
              env=env,
              envFrom=envFrom,
              filesFrom=filesFrom,
              additionalPorts=additionalPorts,
              resources=resources,
              liveness=liveness,
              readiness=readiness,
              startup=startup,
              ingressPort=ingressPort,
            ),
          ],
        },
      },
    },

  /**
  Adds multiple raw extra container specs to the Application pod.
  */
  withExtraContainers(containers)::
    v.array(containers, 'containers') +
    {
      application+: {
        spec+: {
          extraContainers+: containers,
        },
      },
    },
}
+ internalUtils.withArgokitVersionLabel(flavor='v2')
+ ingress
+ replicas
+ environment
+ gcp
+ accessPolicies
+ probes
+ prometheus
+ azureAdApplication
+ configMap
+ externalSecrets
+ mounts
+ utils
+ resources
+ workload
