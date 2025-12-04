local ArgoKitVersionSHA = importstr '../../.git/refs/heads/main';

{
  withArgokitVersionAnnotation():
    {
      metadata+: {
        labels+: {
          'skip.kartverket.no/argokit-version': std.stripChars(ArgoKitVersionSHA, '\n'),
        },
      },
    },
}
