local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;  // simplify statements


local conf = {
  PORT: 3000,
  HOST: 'localhost',
};

local serverSettings = {
  DEBUG: true,
  LOG_LEVEL: 'debug',
};


[
  // config map with as env
  application.new('app', 'foo.io/image', 8080)
  + application.withConfigMapAsEnv(name='db-credentials', data=conf),
  // + application.withConfigMapAsEnv(name='db-credentials', data=conf, addHashToName=true)


  // config map as mount

  application.new('app', 'foo.io/image', 8080)
  + application.withConfigMapAsMount(name='server-settings', mountPath='serverSettings', data=serverSettings, addHashToName=true),
  //+ application.withConfigMapAsMount(name='server-settings', mountPath='serverSettings', data=serverSettings),

]
