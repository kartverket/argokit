local argokit = import '../jsonnet/argokit.libsonnet';


argokit.skipJob.new('a-cool-app')
+ argokit.skipJob.withOutboundSkipApp('appJob', 'mynamespace2')
+ argokit.skipJob.withOutboundHttp('service.kartverket.no')
+ argokit.skipJob.withOutboundPostgres('postgres.kartverket.no', '192.168.1.1')
+ argokit.skipJob.withOutboundOracle('oracle.kartverket.no', '192.168.1.2')
+ argokit.skipJob.withOutboundSsh('ssh.kartverket.no', '192.168.1.3')
+ argokit.skipJob.withOutboundLdaps('ldaps.kartverket.no', '192.168.1.4')
+ argokit.skipJob.withInboundSkipApp('theOtherApp', 'mynamespace')
