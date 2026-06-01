local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

local actual = argokit.dbArchiveJob(
  instanceName='pg-01',
  schedule='0 1 * * *',
  databaseIP='10.0.0.1',
  gcpS3CredentialsSecret='s3-creds',
  databaseName='my-db',
  archiveUser='readonly',
  serviceAccount='archive-sa@project.iam.gserviceaccount.com',
  cloudsqlInstanceConnectionName='project:europe-north1:pg-01',
  port=5433,
  S3Host='s3.example.com',
  S3DestinationPath='s3://bucket/archive',
  fullDump=true,
);

local byName(name) = std.filter(function(item) item.metadata.name == name, actual.items)[0];
local archiveJob = byName('pg-01');
local instanceSecret = byName('cloudsql-pg-01-instance');
local userSecret = byName('cloudsql-pg-01-readonly');
local s3Secret = byName('s3-creds');

test.new(std.thisFile)
+ test.case.new(
  name='dbArchiveJob renders v2 List with SKIPJob',
  test=test.expect.eqDiff(
    actual={
      apiVersion: actual.apiVersion,
      kind: actual.kind,
      items: std.length(actual.items),
      jobApiVersion: archiveJob.apiVersion,
      jobKind: archiveJob.kind,
      hasContainer: std.objectHas(archiveJob.spec, 'container'),
    },
    expected={
      apiVersion: 'v1',
      kind: 'List',
      items: 4,
      jobApiVersion: 'skiperator.kartverket.no/v1beta1',
      jobKind: 'SKIPJob',
      hasContainer: false,
    },
  ),
)
+ test.case.new(
  name='dbArchiveJob sets cron command and gcp auth',
  test=test.expect.eqDiff(
    actual={
      image: archiveJob.spec.image,
      command: archiveJob.spec.command,
      cron: archiveJob.spec.cron,
      serviceAccount: archiveJob.spec.gcp.auth.serviceAccount,
    },
    expected={
      image: 'ghcr.io/kartverket/database-arkiv:7b6dbf1f6542d6359d3929afac3bccfa28d37097',
      command: [
        '/entrypoint.sh',
      ],
      cron: {
        schedule: '0 1 * * *',
        suspend: false,
        startingDeadlineSeconds: 10,
      },
      serviceAccount: 'archive-sa@project.iam.gserviceaccount.com',
    },
  ),
)
+ test.case.new(
  name='dbArchiveJob sets env and secret refs',
  test=test.expect.eqDiff(
    actual={
      database: archiveJob.spec.env[0],
      user: archiveJob.spec.env[1],
      passwordSecret: archiveJob.spec.env[2].valueFrom.secretKeyRef,
      s3AccessKeySecret: archiveJob.spec.env[3].valueFrom.secretKeyRef,
      port: archiveJob.spec.env[10],
      destination: archiveJob.spec.env[11],
      endpoint: archiveJob.spec.env[12],
      fullDump: archiveJob.spec.env[13],
    },
    expected={
      database: {
        name: 'PGDATABASE',
        value: 'my-db',
      },
      user: {
        name: 'PGUSER',
        value: 'readonly',
      },
      passwordSecret: {
        name: 'cloudsql-pg-01-readonly',
        key: 'password',
      },
      s3AccessKeySecret: {
        name: 's3-creds',
        key: 'AWS_ACCESS_KEY_ID',
      },
      port: {
        name: 'PGPORT',
        value: '5433',
      },
      destination: {
        name: 'S3_DESTINATION_PATH',
        value: 's3://bucket/archive',
      },
      endpoint: {
        name: 'S3_ENDPOINT_URL',
        value: 'https://s3.example.com',
      },
      fullDump: {
        name: 'PG_DUMP_ROLES',
        value: 'true',
      },
    },
  ),
)
+ test.case.new(
  name='dbArchiveJob sets network policy and certificate mounts',
  test=test.expect.eqDiff(
    actual={
      outbound: archiveJob.spec.accessPolicy.outbound.external,
      filesFrom: archiveJob.spec.filesFrom,
    },
    expected={
      outbound: [
        {
          host: 'pg-01',
          ip: '10.0.0.1',
          ports: [
            {
              name: 'sql',
              port: 5433,
              protocol: 'TCP',
            },
          ],
        },
        {
          host: 's3.example.com',
          ports: [
            {
              name: 'scality-s3',
              port: 443,
              protocol: 'HTTPS',
            },
          ],
        },
      ],
      filesFrom: [
        {
          mountPath: '/app/db-certs/client',
          secret: 'cloudsql-pg-01-readonly',
          defaultMode: 384,
        },
        {
          mountPath: '/app/db-certs/server',
          secret: 'cloudsql-pg-01-instance',
          defaultMode: 384,
        },
      ],
    },
  ),
)
+ test.case.new(
  name='dbArchiveJob creates external secrets',
  test=test.expect.eqDiff(
    actual={
      instanceSecret: {
        kind: instanceSecret.kind,
        key: instanceSecret.spec.dataFrom[0].extract.key,
      },
      userSecret: {
        kind: userSecret.kind,
        key: userSecret.spec.dataFrom[0].extract.key,
      },
      s3Secret: {
        kind: s3Secret.kind,
        key: s3Secret.spec.dataFrom[0].extract.key,
      },
    },
    expected={
      instanceSecret: {
        kind: 'ExternalSecret',
        key: 'cloudsql-pg-01-instance',
      },
      userSecret: {
        kind: 'ExternalSecret',
        key: 'cloudsql-pg-01-readonly',
      },
      s3Secret: {
        kind: 'ExternalSecret',
        key: 's3-creds',
      },
    },
  ),
)
