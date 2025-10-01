local secret = import 'gsmSecret.libsonnet';
local store = import 'gsmSecretStore.libsonnet';
{
  store: store,
  secret: secret,
}
