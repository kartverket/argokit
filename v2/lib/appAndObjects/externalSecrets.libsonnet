local v = import '../../internal/validation.libsonnet';
local argokit = import '../../jsonnet/argokit.libsonnet';

{
  withEnvironmentVariablesFromExternalSecret(name, creationPolicy=null, secrets=[], allKeysFrom=[], secretStoreRef='gsm')::
    local gsmSecret = argokit.externalSecrets.secret.new(name, creationPolicy, secrets, allKeysFrom, secretStoreRef);
    { objects+:: [gsmSecret] }
    + argokit.appAndObjects.application.withEnvironmentVariablesFromSecret(name),
}
