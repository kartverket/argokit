local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

local environment = argokit.environment;

test.new(std.thisFile)
+ test.case.new(
  name='Standard Variable',
  test=test.expect.eqDiff(
    actual=(environment.withVariable('variableName', 'variableValue') + environment.withVariable('variableName2', 'variableValue2')).spec,
    expected={
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
  ),
)
+ test.case.new(
  name='Standard Secret Variable for job',
  test=test.expect.eqDiff(
    actual=(argokit.SKIPJob('a-job') + environment.withVariableSecret('variableName', 'secretRef', 'key')).spec,
    expected={
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
  ),
)
+ test.case.new(
  name='Standard Secret Variable for job',
  test=test.expect.eqDiff(
    actual=(argokit.Application('a-job') + environment.withVariableSecret('variableName', 'secretRef', 'key')).spec,
    expected={
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
  ),
)
