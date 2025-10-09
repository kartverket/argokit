local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;  // simplify statements

application.new('app')

+ application.withOutboundPostgres(host='postgres-host', ip='10.0.0.1')

+ application.withOutboundOracle(host='oracle-host', ip='10.0.0.1')

+ application.withOutboundSsh(host='ssh-host', ip='10.0.0.1')

+ application.withOutboundLdaps(host='ldaps-host', ip='10.0.0.1')

+ application.withOutboundHttp(host='login.microsoft.com')

+ application.withOutboundSkipApp(appname='foo-backend', namespace='other-team')

+ application.withInboundSkipApp(appname='bar-frontend', namespace='other-team')
