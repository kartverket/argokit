local v = import '../../internal/validation.libsonnet';
local argokit = import '../../jsonnet/argokit.libsonnet';

{
  withEnvironmentVariablesFromExternalSecret(name, secrets=[], allKeysFrom=[])::
    local gsmSecret = argokit.externalSecrets.secret.new(name, secrets, allKeysFrom);
    { objects+:: [gsmSecret] }
    + argokit.appAndObjects.application.withEnvironmentVariablesFromSecret(name),
}
