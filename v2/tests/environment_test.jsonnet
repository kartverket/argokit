local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

test.new(std.thisFile)
+ test.case.new(
  name='Standard Variable',
  test=test.expect.eqDiff(
    actual=(argokit.appAndObjects.application.new('an-app') + argokit.application.withVariable('variableName', 'variableValue') + argokit.application.withVariable('variableName2', 'variableValue2')).spec,
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
    actual=(argokit.appAndObjects.skipJob.new('a-job') + argokit.application.withVariableSecret('variableName', 'secretRef', 'key')).items[0].spec,
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
    actual=(argokit.appAndObjects.application.new('a-job') + argokit.application.withVariableSecret('variableName', 'secretRef', 'key')).items[0].spec,
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
