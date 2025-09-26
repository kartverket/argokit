local argokit = import 'appAndObjects.jsonnet';

local env = 'dev';

local baseApp = {
  spec: {
    image: 'some-image',
    port: 3000,
  },
};

// create the application
baseApp + argokit.application.new('frisk-frontend')

// set environment variables
+ argokit.application.withVariable('VITE_CLIENT_ID', 'some-random-id')
+ argokit.application.withVariable('VITE_AUTHORITY', 'https://login.microsoftonline.com/uri',)
+ argokit.application.withVariable('VITE_LOGIN_REDIRECT_URI', 'https://frisk.atgcp1-' + env + '.kartverket-intern.cloud',)
+ argokit.application.withVariable('VITE_BACKEND_URL', 'https://api.frisk.atgcp1-' + env + '.kartverket-intern.cloud',)
+ argokit.application.withVariable('VITE_REGELRETT_FRONTEND_URL', 'https://regelrett.atgcp1-' + env + '.kartverket-intern.cloud',)
+ argokit.application.withVariable('REGELRETT_CLIENT_ID', if env == 'dev' then 'env-dev' else if env == 'prod' then 'env-prod')


+ argokit.application.withVariable('test', 'bruh')
// set ingress
+ argokit.application.forHostnames('frisk.atgcp1-' + env + '.kartverket-intern.cloud')

// set replicas
+ argokit.application.withReplicas(2, 5, '25m', '128Mi')

// set access policies
+ argokit.application.withOutboundHttp('graph.microsoft.com')
+ argokit.application.withOutboundHttp('login.microsoftonline.com')
+ argokit.application.withOutboundSkipApp('frisk-backend')
