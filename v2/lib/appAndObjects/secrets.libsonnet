local v = import '../../internal/validation.libsonnet';
local argokit = import '../../jsonnet/argokit.libsonnet';

{
  withExternalSecret(name, secrets=[], allKeysFrom=[])::
    local gsmSecret = argokit.secrets.secret.new(name, secrets, allKeysFrom);
    { objects+:: [gsmSecret] }
    + argokit.appAndObjects.application.withSecret(name),
}
