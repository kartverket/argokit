local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;  // simplify statements

application.new('application', 'foo.io/image', 8080)
+ application.withEnvironmentVariable('REDIS_PORT', '6379')

+ application.withEnvironmentVariables({
  DATABASE_PORT: '8000',
  DATABASE_HOST: 'localhost',
})

+ application.withEnvironmentVariableFromSecret(
  'EMAIL_CLIENTID',
  'email-client-id'
)

+ application.withEnvironmentVariableFromSecret(
  'SPRING_DATASOURCE_USERNAME',
  'GRUNNBOK_DATASOURCE_USERNAME',
  'grunnbok-database-username'
)
