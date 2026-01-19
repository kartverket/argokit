/** Creates an external secret store and secret equivalent to externalSecret.yaml. 
Render it out with "skipctl m r -p path/to/externalSecret.jsonnet" and see the similarities
*/
local argokit = import '../../../../jsonnet/argokit.libsonnet';

local secrets = [
  {
    toKey: 'CLIENT_ID',
    fromSecret: 'ansattporten-client-id',
    metadataPolicy: 'None',
    conversionStrategy: "Default", 
    decodingStrategy: "None",
  },
  {
    toKey: 'CLIENT_SECRET',
    fromSecret: 'ansattporten-client-secret',
    metadataPolicy: 'None',
    conversionStrategy: "Default", 
    decodingStrategy: "None",
  },
];
# My secrets and secret stores
local secretStore = argokit.externalSecrets.store.new(name='ansattporten-gsm',gcpProject='tilgangsstyring-sandbox-e5ab');
local secret = argokit.externalSecrets.secret.new(name='ansattporten-secrets',secrets=secrets,secretStoreRef='ansattporten-gsm');

{
  secretStore: secretStore,
  secret: secret,
}