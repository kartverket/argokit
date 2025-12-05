local ArgoKitVersionSHA = importstr '../../.git/refs/heads/main';

{
  withArgokitVersionLabel(version='legacy-version'):
    {
      metadata+: {
        labels+: {
          'skip.kartverket.no/argokit-git-ref': std.stripChars(ArgoKitVersionSHA, '\n'),
          'skip.kartverket.no/argokit-version': version,
        },
      },
    },
}
