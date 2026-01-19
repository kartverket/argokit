/**
This is the redis app defined in the accessPolicy.yaml file 
it is better practice to split up your applications in distinct files rather than 
having multiple in the same file
*/
local argokit = import '../../../../jsonnet/argokit.libsonnet';
local redisApp = argokit.appAndObjects.application;

redisApp.new(name='redis-app',image='redis',port=6379)
# Below defines the access policies
+ redisApp.withInboundSkipApp(appname='nginx-app')
