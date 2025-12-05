local ArgoKitVersionSHA = importstr '../../.git/refs/heads/main';

{
  withArgokitVersionLabel():
    {
      metadata+: {
        labels+: {
          'skip.kartverket.no/argokit-git-ref': std.stripChars(ArgoKitVersionSHA, '\n'),
        },
      },
    },
}
