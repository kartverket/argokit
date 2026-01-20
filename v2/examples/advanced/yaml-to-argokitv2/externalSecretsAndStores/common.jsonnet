/** 
This is an example on how common resources can be defined.
There are other options, but this makes it easy to access the objects.
See "secretApp.jsonnet" to see how easy it is.
*/
local argokit = import '../../../../jsonnet/argokit.libsonnet';

{
  # Some secret stores
  ansattportenSecretStore: argokit.externalSecrets.store.new(name='ansattporten-gsm', gcpProject='some-team-sandbox-aabb'),
  otherSecretStore: argokit.externalSecrets.store.new(name='other-gsm', gcpProject='other-project'),
}