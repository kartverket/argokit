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
          gcp+: { auth: { serviceAccount: serviceAccount } },
        },
      },
    },

  /**
  Configures Cloud SQL Auth Proxy for the pod.
  Parameters:
    - connectionName: string - Cloud SQL connection name, e.g. project:region:instance
    - serviceAccount: string - GCP service account with Cloud SQL client access
    - ip: string - Cloud SQL instance IP address
    - publicIP: bool (optional) - use public IP for the proxy
    - version: string (optional) - Cloud SQL Auth Proxy image version
  */
  withCloudSqlProxy(connectionName, serviceAccount, ip, publicIP=null, version=null)::
    v.string(connectionName, 'connectionName') +
    v.string(serviceAccount, 'serviceAccount') +
    v.string(ip, 'ip') +
    (if publicIP == null then {} else v.boolean(publicIP, 'publicIP')) +
    (if version == null then {} else v.string(version, 'version')) +
    {
      application+: {
        spec+: {
          gcp+: {
            cloudSqlProxy: std.prune({
              connectionName: connectionName,
              serviceAccount: serviceAccount,
              ip: ip,
              publicIP: publicIP,
              version: version,
            }),
          },
        },
      },
    },
}
