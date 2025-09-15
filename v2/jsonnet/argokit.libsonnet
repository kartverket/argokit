local environment = import '../lib/environment.libsonnet';
local accessPolicies = import '../lib/accessPolicies.libsonnet';
local replicas = import '../lib/replicas.libsonnet';
local ingress = import '../lib/ingress.libsonnet';

{
  accessPolicies: accessPolicies,
  environment: environment,
  replicas: replicas,
  ingress: ingress,
  application: {
    new(name): {
      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'Application',
      metadata: {
        name: name,
      },
    },
  },

  azureAdApplication: {
    new(name, namespace='', groups=[], secretPrefix='azuread', allowAllUsers=false, logoutUrl='', replyUrls=[], preAuthorizedApplications=[]):
      {
        apiVersion: 'nais.io/v1',
        kind: 'AzureAdApplication',
        metadata: {
          name: name,
          [if namespace != '' then 'namespace']: namespace,
        },
        spec: {
          secretName: std.format('%s-%s', [secretPrefix, name]),
          allowAllUsers: allowAllUsers,
          replyUrls: std.map(function(x) { url: x }, replyUrls) + [
            {
              url: 'http://localhost/callback',
            },
          ],
          [if logoutUrl != '' then 'logoutUrl']: logoutUrl,
          [if std.length(preAuthorizedApplications) > 0 then 'preAuthorizedApplications']: preAuthorizedApplications,
        } + (if std.length(groups) > 0 then { claims: { groups: groups } } else {}),
      }
      + accessPolicies.withOutboundHttp('login.microsoftonline.com')
      + environment.withSecret(std.format('%s-%s', [secretPrefix, name])),
  },

  skipJob: {
    new(name): {
      apiVersion: 'skiperator.kartverket.no/v1alpha1',
      kind: 'SKIPJob',
      metadata: {
        name: name,
      },
    },
  },
}
