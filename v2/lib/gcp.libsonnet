local v = import '../internal/validation.libsonnet';
{
  /**
  Sets the GCP service account used by the application for Workload Identity.
  Parameters:
    - serviceAccount: string - The email of the GCP service account.
  */
  withGcpServiceAccount(serviceAccount)::
    v.string(serviceAccount, 'serviceAccount') +
    {
      application+: {
        spec+: {
          gcp: { auth: { serviceAccount: serviceAccount } },
        },
      },
    },
}
