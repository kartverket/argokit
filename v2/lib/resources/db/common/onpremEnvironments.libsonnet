local environments = {
  dev: {
    k8sCluster: 'atkv3-dev',
    bucketName: 'dbabucket',
    prettyUrl: 'pg.atkv3-dev',
    gatewayName: 'dba-pg-internal',
    gatewaySectionName: 'pg',
    backupSchedule: '30 16 03 * * MON',
    cidrBlockKubeApi: ['10.40.10.12/32', '10.40.10.13/32', '10.40.10.14/32'],
  },
  dbdev: {
    k8sCluster: 'atkv3-dev-stateful',
    bucketName: 'cnpg-dev',
    prettyUrl: 'db-dev',
    gatewayName: 'istio-internal',
    gatewaySectionName: 'internal-pgdb',
    backupSchedule: '30 16 01 * * MON',
    cidrBlockKubeApi: ['10.40.10.12/32', '10.40.10.13/32', '10.40.10.14/32'],
  },
  sandbox: {
    k8sCluster: 'atkv3-sandbox-stateful',
    bucketName: 'dbabucket',
    prettyUrl: 'db-sandbox',
    gatewayName: 'istio-internal',
    gatewaySectionName: 'internal-pgdb',
    backupSchedule: '30 16 01 * * MON',
    enableBackup: false,
    cidrBlockKubeApi: ['10.40.11.12/32', '10.40.11.13/32', '10.40.11.14/32'],
  },
// prod: {
//  k8sCluster: 'atkv3-prod-stateful',
//  bucketName: 'cnpg-prod',
//  prettyUrl: 'db-prod',
//  gsmProject: 'dba-prod-6849',
//  gatewayName: 'istio-internal',
//  gatewaySectionName: 'internal-pgdb',
//  backupSchedule: '30 16 03 * * *',
//  cidrBlockKubeApi: ['10.40.12.3/32', '10.40.12.4/32', '10.40.12.5/32']
// },
};

{
  get(environment):
    assert std.objectHas(environments, environment) :
      'Unsupported environment: ' + environment;
    environments[environment],
}
