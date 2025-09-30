local v = import '../internal/validation.libsonnet';
local accessPolicies = import '../lib/accessPolicies.libsonnet';
local appAndObjects = import '../lib/appAndObjects.libsonnet';
local hooks = import '../lib/configHooks.libsonnet';
local environment = import '../lib/environment.libsonnet';
local ingress = import '../lib/ingress.libsonnet';
local probes = import '../lib/probes.libsonnet';
local replicas = import '../lib/replicas.libsonnet';
{
  application: {
                 new(name):
                   v.string(name, 'name', allowEmpty=false) +
                   appAndObjects.AppAndObjects {
                     application: {
                       apiVersion: 'skiperator.kartverket.no/v1alpha1',
                       kind: 'Application',
                       metadata: {
                         name: name,
                       },
                     },
                     objects:: [],
                   },
               }
               + ingress
               + replicas
               + environment
               + accessPolicies
               + probes,

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
             new(name):
               v.string(name, 'name', allowEmpty=false) +
               appAndObjects.AppAndObjects {
                 application: {
                   apiVersion: 'skiperator.kartverket.no/v1alpha1',
                   kind: 'SKIPJob',
                   metadata: {
                     name: name,
                   },
                 },
                 objects:: [],
               },
             enableArgokit():
               hooks.normalizeSkipJob({ isSkipJob: true, isAppAndObjects: false }),

           }
           + accessPolicies
           + environment
           + probes,
}
