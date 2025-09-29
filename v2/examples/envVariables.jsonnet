local argokit = import '../../../argokit/jsonnet/argokit.libsonnet';

argokit.Application('a-cool-app') 
+argokit.Env.variable('REDIS_PORT','6379')
+argokit.Env.variableSecret('EMAIL_CLIENTID','email-client-id')
+argokit.Env.variableSecretJob('SLACK_OAUTH_TOKEN','slack-oauth-token')
+argokit.Env.variableSecret('SPRING_DATASOURCE_USERNAME', 'GRUNNBOK_DATASOURCE_USERNAME', 'grunnbok-database-username')
