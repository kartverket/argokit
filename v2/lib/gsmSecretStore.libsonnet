local v = import '../internal/validation.libsonnet';
{
  newExternalSecretStore(gcpProject):
    v.string(gcpProject, 'gcpProject') +
    {
      apiVersion: 'external-secrets.io/v1',
      kind: 'SecretStore',
      metadata: {
        name: 'gsm',
      },
      spec: {
        provider: {
          gcpsm: {
            projectID: gcpProject,
          },
        },
      },
    },

}
