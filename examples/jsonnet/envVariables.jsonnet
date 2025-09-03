local argokit = import '../../../argokit/jsonnet/argokit.libsonnet';

argokit.Application('a-cool-app') 
+argokit.Environment.envVariable('REDIS_PORT','6379')
+argokit.Environment.envVariableSecret('EMAIL_CLIENTID','email-client-id')
+argokit.Environment.envVariableSecretJob('SLACK_OAUTH_TOKEN','slack-oauth-token')
+argokit.Environment.envVariableSecretCustomKey('SPRING_DATASOURCE_USERNAME', 'GRUNNBOK_DATASOURCE_USERNAME', 'grunnbok-database-username')
