local ArgoKitVersionSHA = importstr '../../.git/refs/heads/main';

{
  withArgokitVersionLabel(versionDeprecated=false, flavor='v2'):
    {
      metadata+: {
        labels+: {
          'skip.kartverket.no/argokit-git-ref': std.stripChars(ArgoKitVersionSHA, '\n'),
          'skip.kartverket.no/version-deprecated': versionDeprecated,
          'skip.kartverket.no/argokit-flavor': flavor,
        },
      },
    },
}
