local argokit = import '../jsonnet/argokit.libsonnet';
local job = argokit.job;  // simplify import statement

job.new('test-jonb')
+ job.withOutboundSkipApp('appJob', 'mynamespace2')
+ job.withOutboundHttp('service.kartverket.no')
+ job.withOutboundPostgres('postgres.kartverket.no', '192.168.1.1')
+ job.withOutboundOracle('oracle.kartverket.no', '192.168.1.2')
+ job.withOutboundSsh('ssh.kartverket.no', '192.168.1.3')
+ job.withOutboundLdaps('ldaps.kartverket.no', '192.168.1.4')
+ job.withInboundSkipApp('theOtherApp', 'mynamespace')
