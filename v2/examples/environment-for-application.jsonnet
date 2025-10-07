local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;  // simplify statements

application.new('a-cool-app')
+ application.withEnvironmentVariable('REDIS_PORT', '6379')

+ application.withVariableSecret(
  'EMAIL_CLIENTID',
  'email-client-id'
)

+ application.withVariableSecret(
  'SPRING_DATASOURCE_USERNAME',
  'GRUNNBOK_DATASOURCE_USERNAME',
  'grunnbok-database-username'
)
