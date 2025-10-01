local argokit = import '../jsonnet/argokit.libsonnet';
local secrets = [
  {
    fromSecret: 'test-fromSecret',
    toKey: 'test',
  },
];
local allKeysFrom = [
    {
        fromSecret: 'test-fromSecret'
    }
];
argokit.application.new('my-gsmSecret-app')
+ argokit.application.withVariable('cool-var', 'cool-val')
+ argokit.application.withExternalSecret('super-secret-gsm-app', secrets=secrets,allKeysFrom=allKeysFrom)

