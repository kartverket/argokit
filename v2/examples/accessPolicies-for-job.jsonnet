local argokit = import '../jsonnet/argokit.libsonnet';

local jobAccessPolicies = argokit.accessPolicies.new({ kind: 'SKIPJob' });

argokit.Application('a-cool-app')
+ jobAccessPolicies.withOutboundSkipApp( 'appJob', 'mynamespace2')
+ jobAccessPolicies.withOutboundHttp('service.kartverket.no')
+ jobAccessPolicies.withOutboundPostgres('postgres.kartverket.no', '192.168.1.1')
+ jobAccessPolicies.withOutboundOracle('oracle.kartverket.no', '192.168.1.2')
+ jobAccessPolicies.withOutboundSsh('ssh.kartverket.no', '192.168.1.3')
+ jobAccessPolicies.withOutboundLdaps('ldaps.kartverket.no', '192.168.1.4')
+ jobAccessPolicies.withInboundSkipApp('theOtherApp', 'mynamespace')
