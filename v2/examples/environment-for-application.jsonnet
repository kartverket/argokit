local argokit = import '../jsonnet/argokit.libsonnet';

argokit.Application('a-cool-app')
+ argokit.environment.withVariable('REDIS_PORT', '6379')
+ argokit.environment.withVariableSecret('EMAIL_CLIENTID', 'email-client-id')
+ argokit.environment.withVariableSecret('SPRING_DATASOURCE_USERNAME', 'GRUNNBOK_DATASOURCE_USERNAME', 'grunnbok-database-username')
