local internalUtils = import '../../internal/utils.libsonnet';
local v = import '../../internal/validation.libsonnet';
local accessPolicies = import '../accessPolicies.libsonnet';
local environment = import '../environment.libsonnet';
local gcp = import '../gcp.libsonnet';
local probes = import '../probes.libsonnet';
local prometheus = import '../prometheus.libsonnet';
local resources = import '../specResources.libsonnet';
local workload = import '../workload.libsonnet';
local configMap = import './configMap.libsonnet';
local externalSecrets = import './externalSecrets.libsonnet';
local mounts = import './mounts.libsonnet';
local templates = import './templates.libsonnet';
local utils = import './utils.libsonnet';

local optionalString(value, label) =
  if value == null then {} else v.string(value, label);

local optionalNumber(value, label) =
  v.number(value, label, true);

local optionalBoolean(value, label) =
  if value == null then {} else v.boolean(value, label);

local enum(value, label, allowed, allowNull=false) =
  if allowNull && value == null then {}
  else if std.member(allowed, value) then {}
  else error label + ' must be one of: ' + std.join(', ', allowed);

{
  new(name, image):
    v.string(name, 'name') +
    v.string(image, 'image') +
    templates.AppAndObjects {
      application:: {
        apiVersion: 'skiperator.kartverket.no/v1beta1',
        kind: 'SKIPJob',
        metadata: {
          name: name,
        },
        spec+: {
          image: image,
        },
      },
      objects:: [],
    },

  /**
  Configures the SKIPJob as a scheduled job.
  */
  withCron(schedule, allowConcurrency=null, startingDeadlineSeconds=null, suspend=null, timeZone=null)::
    v.string(schedule, 'schedule') +
    enum(allowConcurrency, 'allowConcurrency', ['Allow', 'Forbid', 'Replace'], allowNull=true) +
    optionalNumber(startingDeadlineSeconds, 'startingDeadlineSeconds') +
    optionalBoolean(suspend, 'suspend') +
    optionalString(timeZone, 'timeZone') +
    {
      application+: {
        spec+: {
          cron: std.prune({
            schedule: schedule,
            allowConcurrency: allowConcurrency,
            startingDeadlineSeconds: startingDeadlineSeconds,
            suspend: suspend,
            timeZone: timeZone,
          }),
        },
      },
    },

  /**
  Configures Kubernetes Job settings.
  */
  withSettings(activeDeadlineSeconds=null, backoffLimit=null, suspend=null, ttlSecondsAfterFinished=null)::
    optionalNumber(activeDeadlineSeconds, 'activeDeadlineSeconds') +
    optionalNumber(backoffLimit, 'backoffLimit') +
    optionalBoolean(suspend, 'suspend') +
    optionalNumber(ttlSecondsAfterFinished, 'ttlSecondsAfterFinished') +
    {
      application+: {
        spec+: {
          job: std.prune({
            activeDeadlineSeconds: activeDeadlineSeconds,
            backoffLimit: backoffLimit,
            suspend: suspend,
            ttlSecondsAfterFinished: ttlSecondsAfterFinished,
          }),
        },
      },
    },

  /**
  Sets the job restart policy.
  */
  withRestartPolicy(restartPolicy)::
    enum(restartPolicy, 'restartPolicy', ['OnFailure', 'Never']) +
    {
      application+: {
        spec+: {
          restartPolicy: restartPolicy,
        },
      },
    },
}
+ internalUtils.withArgokitVersionLabel(flavor='v2')
+ accessPolicies
+ environment
+ gcp
+ probes
+ prometheus
+ configMap
+ externalSecrets
+ mounts
+ utils
+ resources
+ workload
