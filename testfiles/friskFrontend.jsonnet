local application = function(name='frisk-frontend', env, version, VITE_CLIENT_ID)
  {
    apiVersion: 'skiperator.kartverket.no/v1alpha1',
    kind: 'Application',
    metadata: {
      name: name,
    },
    spec: {
      image: version,
      port: 3000,
      ingresses: ['frisk.atgcp1-' + env + '.kartverket-intern.cloud'],
      replicas: {
        min: 2,
        max: 5,
        targetCpuUtilization: '25m',
        targetMemoryUtilization: '128Mi',

      },
      accessPolicy: {
        outbound: {
          rules: [
            {
              application: 'frisk-backend',
            },
          ],
          external: [
            {
              host: 'graph.microsoft.com',
            },
            {
              host: 'login.microsoftonline.com',
            },
          ],
        },
      },
      env: [
        {
          name: 'VITE_CLIENT_ID',
          value: VITE_CLIENT_ID,
        },
        {
          name: 'VITE_AUTHORITY',
          value: 'https://login.microsoftonline.com/uri',
        },
        {
          name: 'VITE_LOGIN_REDIRECT_URI',
          value: 'https://frisk.atgcp1-' + env + '.kartverket-intern.cloud',
        },
        {
          name: 'VITE_BACKEND_URL',
          value: 'https://api.frisk.atgcp1-' + env + '.kartverket-intern.cloud',
        },
        {
          name: 'VITE_REGELRETT_FRONTEND_URL',
          value: 'https://regelrett.atgcp1-' + env + '.kartverket-intern.cloud',
        },
        {
          name: 'REGELRETT_CLIENT_ID',
          value: if env == 'dev' then 'env-dev'
          else if env == 'prod' then 'env-prod',
        },
      ],
    },
  };

application(
  env='dev',
  version='some-image',
  VITE_CLIENT_ID='some-random-id',
)
