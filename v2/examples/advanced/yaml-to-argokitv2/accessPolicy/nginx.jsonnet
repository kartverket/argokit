/**
This is the nginx app defined in the accessPolicy.yaml file 
it is better practice to split up your applications in distinct files rather than 
having multiple in the same file
*/

local argokit = import '../../../../jsonnet/argokit.libsonnet';
local nginxApp = argokit.appAndObjects.application;

nginxApp.new(name='nginx-app',image='nginx',port=8080)
# Below defines the access policies
+ nginxApp.withOutboundSkipApp(appname='redis-app')
