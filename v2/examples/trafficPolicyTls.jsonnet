local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;

application.new('my-app', 'myapp:1.0.0', 8080)
+ application.withTrafficPolicyTls(
  name='jenkins-matrikkel-no',
  host='jenkins.matrikkel.no',
  tlsMode='SIMPLE',
  sni='jenkins.matrikkel.no'
)
