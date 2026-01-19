local argokit = import '../../../../jsonnet/argokit.libsonnet'; # remember to use YOUR correct path here
local application = argokit.appAndObjects.application;

function(name, env, version)
  application.new(name=name, image=version, port=3000)
  + application.forHostnames('devex.demo-frontend-' + env + '.host.com')
  + application.withOutboundSkipApp('demo-backend')
  + application.withEnvironmentVariables({
    VITE_AUTHORITY: 'https://login.microsoftonline.com/1234-5678/v2.0',
    VITE_FRONTEND_URL: 'https://devex.atgcp1-' + env + '.host.com',
    VITE_CLIENT_ID: if env == 'dev' then 'abcd-efgh-1234-5678' else if env == 'prod' then 'xyz-123-asdf',
    VITE_BACKEND_URL: '/api',
  })