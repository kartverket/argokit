local version = import '../../version.libsonnet';

{
  withArgokitVersionLabel(versionDeprecated=null, flavor='v2'):
    {
      metadata+: {
        labels+: {
          'skip.kartverket.no/argokit-git-ref': version.sha,
          'skip.kartverket.no/argokit-tag': version.tag,
          'skip.kartverket.no/argokit-flavor': flavor,
          [if versionDeprecated != null then 'skip.kartverket.no/argokit-deprecated-version']: std.toString(versionDeprecated),
        },
      },
    },
}
