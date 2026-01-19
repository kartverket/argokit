/** Create an app manifest using external secret store and secret */
local argokit = import '../../../../jsonnet/argokit.libsonnet';
local common = import 'common.jsonnet'; # definition of secret store is here

local secretApp = argokit.appAndObjects.application;

# Define desired secrets
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
# Create the secretApp manifest with an external secret and secret store (from common.jsonnet)
secretApp.new(name='secret-app',image='secret-image',port=8080)
+ secretApp.withEnvironmentVariablesFromExternalSecret(
    name='ansattporten-secrets',
    secrets=secrets,
    secretStoreRef=common.ansattportenSecretStore.metadata.name) 
# The secret store can be added to the manifest like below, if it not already deployed
// + secretApp.withObjects(common.ansattportenSecretStore)