local v = import '../internal/validation.libsonnet';

local optionalNumber(value, label) =
  v.number(value, label, true);

local optionalBoolean(value, label) =
  if value == null then {} else v.boolean(value, label);

local enum(value, label, allowed) =
  if std.member(allowed, value) then {}
  else error label + ' must be one of: ' + std.join(', ', allowed);

{
  /**
  Sets the command for the workload container.
  */
  withCommand(command)::
    v.array(command, 'command') +
    {
      application+: {
        spec+: {
          command: command,
        },
      },
    },

  /**
  Adds labels propagated by Skiperator to generated resources.
  */
  withLabels(labels)::
    v.object(labels, 'labels') +
    {
      application+: {
        spec+: {
          labels+: labels,
        },
      },
    },

  /**
  Sets the owning team for the workload.
  */
  withTeam(team)::
    v.string(team, 'team') +
    {
      application+: {
        spec+: {
          team: team,
        },
      },
    },

  /**
  Sets SKIP resource priority.
  */
  withPriority(priority)::
    enum(priority, 'priority', ['low', 'medium', 'high']) +
    {
      application+: {
        spec+: {
          priority: priority,
        },
      },
    },

  /**
  Adds an additional container port.
  */
  withAdditionalPort(name, port, protocol='TCP')::
    v.string(name, 'name') +
    v.number(port, 'port') +
    enum(protocol, 'protocol', ['TCP', 'UDP', 'SCTP']) +
    {
      application+: {
        spec+: {
          additionalPorts+: [
            {
              name: name,
              port: port,
              protocol: protocol,
            },
          ],
        },
      },
    },

  /**
  Configures pod-level settings for pods created by Skiperator.
  */
  withPodSettings(annotations={}, disablePodSpreadTopologyConstraints=null, terminationGracePeriodSeconds=null)::
    v.object(annotations, 'annotations', allowEmpty=true) +
    optionalBoolean(disablePodSpreadTopologyConstraints, 'disablePodSpreadTopologyConstraints') +
    optionalNumber(terminationGracePeriodSeconds, 'terminationGracePeriodSeconds') +
    {
      application+: {
        spec+: {
          podSettings: std.prune({
            annotations: annotations,
            disablePodSpreadTopologyConstraints: disablePodSpreadTopologyConstraints,
            terminationGracePeriodSeconds: terminationGracePeriodSeconds,
          }),
        },
      },
    },

  /**
  Sets Istio tracing sampling percentage. Use 0 to disable tracing.
  */
  withTracing(randomSamplingPercentage)::
    v.number(randomSamplingPercentage, 'randomSamplingPercentage') +
    v.require(randomSamplingPercentage >= 0 && randomSamplingPercentage <= 100, 'randomSamplingPercentage must be between 0 and 100') +
    {
      application+: {
        spec+: {
          istioSettings+: {
            telemetry+: {
              tracing: [
                {
                  randomSamplingPercentage: randomSamplingPercentage,
                },
              ],
            },
          },
        },
      },
    },
}
