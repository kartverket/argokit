local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;
test.new(std.thisFile)
+ test.case.new(
  name='Standard Variable',
  test=test.expect.eqDiff(
    actual=(application.withEnvironmentVariable('variableName', 'variableValue') + application.withEnvironmentVariable('variableName2', 'variableValue2')).application.spec,
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
    actual=(application.withVariableSecret('variableName', 'secretRef', 'key')).application.spec,
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
