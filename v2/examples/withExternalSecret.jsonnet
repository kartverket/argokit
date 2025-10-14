local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;  // simplify statements
local secrets = [
  {
    fromSecret: 'test-fromSecret',
    toKey: 'test',
  },
];
local allKeysFrom = [
  {
    fromSecret: 'test-fromSecret',
  },
];
application.new('my-gsmSecret-app', 'foo.io/image', 8080)
+ application.withEnvironmentVariable('cool-var', 'cool-val')
+ application.withEnvironmentVariablesFromExternalSecret(
  name='super-secret-gsm-app',
  secrets=secrets,
  allKeysFrom=allKeysFrom
)
