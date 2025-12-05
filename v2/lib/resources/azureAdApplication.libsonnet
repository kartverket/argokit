local utils = import '../../internal/utils.libsonnet';
local v = import '../../internal/validation.libsonnet';
{
  new(
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
    v.string(name, 'name') +
    v.string(namespace, 'namespace', allowEmpty=true) +
    v.array(groups, 'groups', allowEmpty=true) +
    v.string(secretPrefix, 'secretPrefix') +
    v.boolean(allowAllUsers, 'allowAllUsers') +
    v.string(logoutUrl, 'logoutUrl', allowEmpty=true) +
    v.array(replyUrls, 'replyUrls', allowEmpty=true) +
    v.array(preAuthorizedApplications, 'preAuthorizedApplications', allowEmpty=true) +

    {
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
    } + utils.withArgokitVersionLabel(false ,'v2'),
}
