local argokit = import '../jsonnet/argokit.libsonnet';

local jobEnvironment = argokit.jobEnvironment.new({ kind: 'SKIPJob' });

argokit.Application('a-cool-app')
+ jobEnvironment.withVariable('REDIS_PORT', '6379')
+ jobEnvironment.withVariableSecret('EMAIL_CLIENTID', 'email-client-id')
+ jobEnvironment.withVariableSecret('SPRING_DATASOURCE_USERNAME', 'GRUNNBOK_DATASOURCE_USERNAME', 'grunnbok-database-username')
               