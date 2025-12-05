local ArgoKitVersionSHA = importstr '../../.git/refs/heads/main';

{
  withArgokitVersionLabel(versionDeprecated=true):
    {
      metadata+: {
        labels+: {
          'skip.kartverket.no/argokit-git-ref': std.stripChars(ArgoKitVersionSHA, '\n'),
          'skip.kartverket.no/version-deprecated': versionDeprecated,
        },
      },
    },
}
