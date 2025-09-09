local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

local jobEnvironment = argokit.environment.new({ kind: 'SKIPJob' });
local appEnvironment = argokit.environment.new({ kind: 'SKIPApp' });


test.new(std.thisFile)
+ test.case.new(
  name='Standard Variable',
  test=test.expect.eqDiff(
    actual=jobEnvironment.withVariable('variableName', 'variableValue') + jobEnvironment.withVariable('variableName2', 'variableValue2'),
    expected={
      spec: {
        env: [
          {
            name: 'variableName',
            value: 'variableValue',
          },
          {
            name: 'variableName2',
            value: 'variableValue2',
          },
        ],
      },
    }
  ),
)
+ test.case.new(
  name='Standard Secret Variable for job',
  test=test.expect.eqDiff(
    actual=jobEnvironment.withVariableSecret('variableName', 'secretRef', 'key'),
    expected={
      spec: {
        container: {
          env: [
            {
              name: 'variableName',
              valueFrom: {
                secretKeyRef: {
                  name: 'secretRef',
                  key: 'key',
                },
              },
            },
          ],
        },
      },
    }
  ),
)
+ test.case.new(
  name='Standard Secret Variable for job',
  test=test.expect.eqDiff(
    actual=appEnvironment.withVariableSecret('variableName', 'secretRef', 'key'),
    expected={
      spec: {
        env: [
          {
            name: 'variableName',
            valueFrom: {
              secretKeyRef: {
                name: 'secretRef',
                key: 'key',
              },
            },
          },
        ],
      },
    }
  ),
)
