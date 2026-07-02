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

local cronSyntaxError =
  'schedule must use Kubernetes cron syntax: five fields with minute 0-59, hour 0-23, day-of-month 1-31, month 1-12, and day-of-week 0-6; lists, ranges, ?, macros, and positive Vixie steps are supported';

local cronMacros = [
  '@yearly',
  '@annually',
  '@monthly',
  '@weekly',
  '@daily',
  '@midnight',
  '@hourly',
];

local isInteger(value) =
  std.length(value) > 0
  && std.all([
    local cp = std.codepoint(char);
    cp >= 48 && cp <= 57
    for char in std.stringChars(value)
  ]);

local inRange(value, min, max) =
  isInteger(value)
  && (local n = std.parseInt(value); n >= min && n <= max);

local validCronBase(value, min, max) =
  if value == '*' || value == '?' then true
  else
    local parts = std.split(value, '-');
    local len = std.length(parts);
    (len == 1 || len == 2)
    && inRange(parts[0], min, max)
    && (len == 1 || (
          inRange(parts[1], min, max)
          && std.parseInt(parts[0]) <= std.parseInt(parts[1])
        ));

local validCronPart(value, min, max) =
  local stepParts = std.split(value, '/');
  std.length(stepParts) >= 1
  && std.length(stepParts) <= 2
  && validCronBase(stepParts[0], min, max)
  && (
    std.length(stepParts) == 1
    || (isInteger(stepParts[1]) && std.parseInt(stepParts[1]) > 0)
  );

local validCronField(value, min, max) =
  std.length(value) > 0
  && std.all([validCronPart(part, min, max) for part in std.split(value, ',')]);

local validCronSchedule(schedule) =
  local fields = [field for field in std.split(schedule, ' ') if field != ''];
  std.member(cronMacros, schedule)
  ||
  (
    std.length(fields) == 5
    && validCronField(fields[0], 0, 59)
    && validCronField(fields[1], 0, 23)
    && validCronField(fields[2], 1, 31)
    && validCronField(fields[3], 1, 12)
    && validCronField(fields[4], 0, 6)
  );

local validateCronSchedule(schedule) =
  if validCronSchedule(schedule) then {} else error cronSyntaxError;

{
  _cronScheduleIsValid(schedule):: validCronSchedule(schedule),

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
  Parameters:
    - schedule: string - cron expression (five fields) or macro such as @daily. Validated at render time.
    - allowConcurrency: string (optional) - how to handle overlapping runs: Allow, Forbid, or Replace.
    - startingDeadlineSeconds: number (optional) - seconds after a missed start before the run is skipped.
    - suspend: boolean (optional) - suspend the resource without deleting it.
    - timeZone: string - IANA time zone for the schedule, e.g. Etc/UTC. Defaults to Europe/Oslo.
  */
  withCron(schedule, allowConcurrency=null, startingDeadlineSeconds=null, suspend=null, timeZone='Europe/Oslo')::
    v.string(schedule, 'schedule') +
    validateCronSchedule(schedule) +
    v.enum(allowConcurrency, 'allowConcurrency', ['Allow', 'Forbid', 'Replace'], allowNull=true) +
    v.optionalNumber(startingDeadlineSeconds, 'startingDeadlineSeconds') +
    v.optionalBoolean(suspend, 'suspend') +
    v.optionalString(timeZone, 'timeZone') +
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
  Parameters:
    - activeDeadlineSeconds: number (optional) - hard time limit in seconds for the entire job.
    - backoffLimit: number (optional) - number of retries before the job is marked failed. 0 means no retries.
    - suspend: boolean (optional) - suspend the resource without deleting it.
    - ttlSecondsAfterFinished: number (optional) - seconds to keep the finished job before garbage collection.
  */
  withSettings(activeDeadlineSeconds=null, backoffLimit=null, suspend=null, ttlSecondsAfterFinished=null)::
    v.optionalNumber(activeDeadlineSeconds, 'activeDeadlineSeconds') +
    v.optionalNumber(backoffLimit, 'backoffLimit') +
    v.optionalBoolean(suspend, 'suspend') +
    v.optionalNumber(ttlSecondsAfterFinished, 'ttlSecondsAfterFinished') +
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
  Sets the job restart policy. OnFailure restarts the container in-place; Never leaves the pod for inspection.
  Parameters:
    - restartPolicy: string - OnFailure or Never.
  */
  withRestartPolicy(restartPolicy)::
    v.enum(restartPolicy, 'restartPolicy', ['OnFailure', 'Never']) +
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
