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

local digits = [
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
];

local isInteger(value) =
  std.length(value) > 0
  && std.length([char for char in std.stringChars(value) if !std.member(digits, char)]) == 0;

local inRange(value, min, max) =
  isInteger(value)
  && std.parseInt(value) >= min
  && std.parseInt(value) <= max;

local validCronBase(value, min, max) =
  if value == '*' || value == '?' then true
  else
    local rangeParts = std.split(value, '-');
    if std.length(rangeParts) == 1 then inRange(value, min, max)
    else if std.length(rangeParts) == 2 then
      inRange(rangeParts[0], min, max)
      && inRange(rangeParts[1], min, max)
      && std.parseInt(rangeParts[0]) <= std.parseInt(rangeParts[1])
    else false;

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
  && std.length([part for part in std.split(value, ',') if !validCronPart(part, min, max)]) == 0;

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
  */
  withCron(schedule, allowConcurrency=null, startingDeadlineSeconds=null, suspend=null, timeZone=null)::
    v.string(schedule, 'schedule') +
    validateCronSchedule(schedule) +
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
