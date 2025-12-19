local argokit = import '../jsonnet/argokit.libsonnet';
local app = argokit.appAndObjects.application;

local app = argokit.appAndObjects.application;

app.new('my-app', 'my-image:latest', 8080)
+ app.resources.withRequests(cpu='1',memory=1000)
+ app.resources.withLimits(cpu='2',memory=2000)