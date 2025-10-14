local v = import '../../internal/validation.libsonnet';
local argokit = import '../../jsonnet/argokit.libsonnet';

{
  withEnvironmentVariablesFromExternalSecret(name, secrets=[], allKeysFrom=[], secretStoreRef)::
    local gsmSecret = argokit.externalSecrets.secret.new(name, secrets, allKeysFrom, secretStoreRef);
    { objects+:: [gsmSecret] }
    + argokit.appAndObjects.application.withEnvironmentVariablesFromSecret(name),
}
