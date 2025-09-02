local argokit = import '../../../argokit/jsonnet/argokit.libsonnet';

argokit.Application('a-cool-app') 
+ argokit.AppAndObjects.envVariable('REDIS_PORT','6379')
+argokit.AppAndObjects.envVariableSecret('EMAIL_CLIENTID','email-client-id')
+argokit.AppAndObjects.envVariableSecretJob('SLACK_OAUTH_TOKEN','slack-oauth-token')
+argokit.AppAndObjects.envVariableSecretCustomKey('SPRING_DATASOURCE_USERNAME', 'GRUNNBOK_DATASOURCE_USERNAME', 'grunnbok-database-username')
