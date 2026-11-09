local serviceEntryS3 = {
  apiVersion: 'networking.istio.io/v1',
  kind: 'ServiceEntry',
  metadata: {
    name: 's3-scality-barman',
  },
  spec: {
    exportTo: ['.'],
    hosts: ['s3-rin.statkart.no'],
    ports: [
      {
        number: 443,
        name: 'https',
        protocol: 'HTTPS',
      },
    ],
    resolution: 'DNS',
  },
};

local objectStore(bucketName, storeName, destinationName) = {
  apiVersion: 'barmancloud.cnpg.io/v1',
  kind: 'ObjectStore',
  metadata: {
    name: storeName,
  },
  spec: {
    instanceSidecarConfiguration: {
      env: [
        {
          name: 'AWS_REQUEST_CHECKSUM_CALCULATION',
          value: 'when_required',
        },
        {
          name: 'AWS_RESPONSE_CHECKSUM_VALIDATION',
          value: 'when_supported',
        },
        {
          name: 'AWS_SKIP_MD5_VALIDATION',
          value: 'true',
        },
      ],
    },
    retentionPolicy: '7d',
    configuration: {
      destinationPath: 's3://%s/%s' % [bucketName, destinationName],
      endpointURL: 'https://s3-rin.statkart.no',
      s3Credentials: {
        accessKeyId: {
          name: 's3-bucket-creds',
          key: 'ACCESS_KEY_ID',
        },
        secretAccessKey: {
          name: 's3-bucket-creds',
          key: 'ACCESS_SECRET_KEY',
        },
      },
      wal: {
        compression: 'gzip',
      },
    },
  },
};

{
  serviceEntryS3: serviceEntryS3,
  objectStore: objectStore,
  new(p, clusterName, bucketName, backupSchedule, enableBackup): {
    serviceEntryS3: serviceEntryS3,
    objectStore: objectStore(bucketName, 's3-store', p.databaseName),
    [if enableBackup then 'scheduledBackupJob']: {
      apiVersion: 'postgresql.cnpg.io/v1',
      kind: 'ScheduledBackup',
      metadata: {
        name: 'backup-' + clusterName,
      },
      spec: {
        schedule: backupSchedule,
        backupOwnerReference: 'self',
        cluster: {
          name: clusterName,
        },
        method: 'plugin',
        pluginConfiguration: {
          name: 'barman-cloud.cloudnative-pg.io',
        },
      },
    },
  },
}
