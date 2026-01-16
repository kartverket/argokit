/**
This is the redis app defined in the accessPolicy.yaml file 
it is better practice to split up your applications in distinct files rather than 
having multiple in the same file
*/
local argokit = import '../../../../jsonnet/argokit.libsonnet';
local redisApp = argokit.appAndObjects.application;

redisApp.new(name='redis-app',image='redis',port=8080)
# Below defines the access policies
+ redisApp.withOutboundSkipApp(appname='nginx-app')
+ redisApp.withInboundSkipApp(appname='nginx-app')
