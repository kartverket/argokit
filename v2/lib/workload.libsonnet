local v = import '../internal/validation.libsonnet';

{
  /**
  Sets the command for the workload container, overriding the image's default entrypoint.
  Parameters:
    - command: array - command and arguments, e.g. ['sh', '-c', 'migrate && serve'].
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
  Adds labels propagated by Skiperator to all generated resources (Deployment, Service, etc.).
  Parameters:
    - labels: object - key/value pairs to merge into the resource labels.
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
  Sets the owning team for the workload. Used by Skiperator for labelling and tracking ownership.
  Parameters:
    - team: string - team identifier.
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
  Sets SKIP resource priority, which controls scheduling preference under resource pressure.
  Parameters:
    - priority: string - low, medium, or high.
  */
  withPriority(priority)::
    v.enum(priority, 'priority', ['low', 'medium', 'high']) +
    {
      application+: {
        spec+: {
          priority: priority,
        },
      },
    },

  /**
  Exposes an additional container port alongside the main port (e.g. a metrics scrape port).
  Parameters:
    - name: string - port name, used as the key in Service and NetworkPolicy.
    - port: number - port number.
    - protocol: string - TCP (default), UDP, or SCTP.
  */
  withAdditionalPort(name, port, protocol='TCP')::
    v.string(name, 'name') +
    v.number(port, 'port') +
    v.enum(protocol, 'protocol', ['TCP', 'UDP', 'SCTP']) +
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
  Parameters:
    - annotations: object (optional) - annotations added to every pod.
    - disablePodSpreadTopologyConstraints: boolean (optional) - opt out of Skiperator's default topology spread constraints.
    - terminationGracePeriodSeconds: number (optional) - seconds to wait for graceful shutdown before SIGKILL.
  */
  withPodSettings(annotations=null, disablePodSpreadTopologyConstraints=null, terminationGracePeriodSeconds=null)::
    (if annotations != null then v.object(annotations, 'annotations', allowEmpty=true) else {}) +
    v.optionalBoolean(disablePodSpreadTopologyConstraints, 'disablePodSpreadTopologyConstraints') +
    v.optionalNumber(terminationGracePeriodSeconds, 'terminationGracePeriodSeconds') +
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
  Sets Istio distributed tracing sampling rate.
  Parameters:
    - randomSamplingPercentage: number - percentage of requests to trace, 0–100. Use 0 to disable tracing.
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
