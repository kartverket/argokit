local v = import '../../internal/validation.libsonnet';
local argokit = import '../../jsonnet/argokit.libsonnet';
{
  withAzureAdApplication(
    name,
    namespace='',
    groups=[],
    secretPrefix='azuread',
    allowAllUsers=false,
    logoutUrl='',
    replyUrls=[],
    preAuthorizedApplications=[]
  )::
    local azureAdApp = argokit.azureAdApplication.new(
      name, namespace, groups, secretPrefix, allowAllUsers, logoutUrl, replyUrls, preAuthorizedApplications
    );

    // add the azure ad application to the objects of the AppAndObjects
    { objects+:: [azureAdApp] }
    // add necessary config to the main application
    + argokit.appAndObjects.application.withOutboundHttp('login.microsoftonline.com')
    + argokit.appAndObjects.application.withSecret(std.format('%s-%s', [secretPrefix, name])),
}
