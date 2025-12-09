local ArgoKitVersionSHA = importstr '../../.git/refs/heads/main';

{
  withArgokitVersionLabel(versionDeprecated=null, flavor='v2'):
    {
      metadata+: {
        labels+: {
          'skip.kartverket.no/argokit-git-ref': std.stripChars(ArgoKitVersionSHA, '\n'),
          'skip.kartverket.no/argokit-flavor': flavor,
          [if versionDeprecated != null then 'skip.kartverket.no/argokit-deprecated-version']: versionDeprecated,
        },
      },
    },
}
