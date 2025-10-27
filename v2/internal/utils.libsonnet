local ArgoKitVersionSHA = importstr '../../.git/refs/heads/main';

{
  withArgokitVersionAnnotation():
    {
      metadata+: {
        annotations+: {
          'skip.kartverket.no/argokit-version': std.stripChars(ArgoKitVersionSHA, '\n'),
        },
      },
    },
}
