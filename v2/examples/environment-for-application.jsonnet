local argokit = import '../jsonnet/argokit.libsonnet';

argokit.application.new('a-cool-app')
+ argokit.application.withVariable('REDIS_PORT', '6379')
+ argokit.application.withVariableSecret(
    'EMAIL_CLIENTID',
    'email-client-id')
+ argokit.application.withVariableSecret(
    'SPRING_DATASOURCE_USERNAME',
    'GRUNNBOK_DATASOURCE_USERNAME',
    'grunnbok-database-username')
