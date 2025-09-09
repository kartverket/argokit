local argokit = import '../jsonnet/argokit.libsonnet';

local accessPolicies = argokit.accessPolicies;

argokit.SKIPJob('a-cool-app')
+ accessPolicies.withOutboundSkipApp( 'appJob', 'mynamespace2')
+ accessPolicies.withOutboundHttp('service.kartverket.no')
+ accessPolicies.withOutboundPostgres('postgres.kartverket.no', '192.168.1.1')
+ accessPolicies.withOutboundOracle('oracle.kartverket.no', '192.168.1.2')
+ accessPolicies.withOutboundSsh('ssh.kartverket.no', '192.168.1.3')
+ accessPolicies.withOutboundLdaps('ldaps.kartverket.no', '192.168.1.4')
+ accessPolicies.withInboundSkipApp('theOtherApp', 'mynamespace')
