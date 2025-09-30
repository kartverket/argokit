local v = import '../internal/validation.libsonnet';
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
    // input parameter validation
    v.string(name, 'name', allowEmpty=false) +
    v.string(namespace, 'namespace') +
    v.array(groups, 'groups') +
    v.string(secretPrefix, 'secretPrefix', allowEmpty=false) +
    v.boolean(allowAllUsers, 'allowAllUsers') +
    v.string(logoutUrl, 'logoutUrl') +
    v.array(replyUrls, 'replyUrls') +
    v.array(preAuthorizedApplications, 'preAuthorizedApplications') +

    local azureAdApp = {
      apiVersion: 'nais.io/v1',
      kind: 'AzureAdApplication',
      metadata: {
        name: name,
        [if namespace != '' then 'namespace']: namespace,
      },
      spec: {
        secretName: std.format('%s-%s',
                               [secretPrefix, name]),
        allowAllUsers: allowAllUsers,
        replyUrls: std.map(function(x) { url: x }, replyUrls) + [
          {
            url: 'http://localhost/callback',
          },
        ],
        [if logoutUrl != '' then 'logoutUrl']: logoutUrl,
        [if std.length(preAuthorizedApplications) > 0 then 'preAuthorizedApplications']: preAuthorizedApplications,
      } + (if std.length(groups) > 0 then { claims: { groups: groups } } else {}),
    };

    // add the azure ad application to the objects of the AppAndObjects
    { objects+:: [azureAdApp] }
    // add necessary config to the main application
    + self.withOutboundHttp('login.microsoftonline.com')
    + self.withSecret(std.format('%s-%s', [secretPrefix, name])),
}
