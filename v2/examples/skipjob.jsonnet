local argokit = import '../jsonnet/argokit.libsonnet';
local skipjob = argokit.appAndObjects.skipjob;

skipjob.new('daily-report', 'ghcr.io/kartverket/daily-report:latest')
+ skipjob.withCommand([
  'sh',
  '-c',
  'run-report',
])
+ skipjob.withCron(
  schedule='0 6 * * *',
  timeZone='Europe/Oslo',
)
+ skipjob.withSettings(
  backoffLimit=1,
  ttlSecondsAfterFinished=3600,
)
+ skipjob.withEnvironmentVariable('ENVIRONMENT', 'prod')
+ skipjob.withGcpServiceAccount('daily-report@project.iam.gserviceaccount.com')
+ skipjob.withPrometheus(path='/metrics', port=8080)
