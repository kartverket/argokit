local externalSecrets = import '../../externalSecrets.libsonnet';

{
  new(p, clusterName):
    assert std.objectHas(p, 'users') :
      'users must exist and needs to contain at least one user';
    local managedRoles = p.users;
    local rolesWithWrite = [
      name for name in std.objectFields(managedRoles)
      if managedRoles[name].isWriteUser
    ];
    local dbOwner =
      if std.length(rolesWithWrite) > 0 then rolesWithWrite[0] else p.databaseName;
    local roles = {
      ['databaserole-%s' % name]: {
        apiVersion: 'postgresql.cnpg.io/v1',
        kind: 'DatabaseRole',
        metadata: {
          name: 'pg-role-' + name,
        },
        spec: {
          cluster: {
            name: clusterName,
          },
          name: name,
          comment:
            if managedRoles[name].isWriteUser
            then 'Managed role for write user'
            else 'Managed role for read-only user',
          createdb: managedRoles[name].isWriteUser,
          createrole: managedRoles[name].isWriteUser,
          inherit: true,
          databaseRoleReclaimPolicy:
            if std.objectHas(managedRoles[name], 'delete') && managedRoles[name].delete
            then 'delete'
            else 'retain',
          inRoles:
            if managedRoles[name].isWriteUser
            then ['pg_write_all_data', 'pg_read_all_data']
            else ['pg_read_all_data'],
          passwordSecret: {
            name: 'pg-role-' + name,
          },
          login: true,
          superuser: false,
          bypassrls: false,
          replication: false,
        },
      }
      for name in std.objectFields(managedRoles)
    };
    local roleSecrets = {
      ['external-secret-pg-role-%s' % name]: externalSecrets.secret.new(
        name='pg-role-' + name,
        secrets=[
          {
            fromSecret: 'pg-role-' + name,
            property: 'username',
            toKey: 'username',
          },
          {
            fromSecret: 'pg-role-' + name,
            property: 'password',
            toKey: 'password',
          },
        ],
        secretStoreRef='gsm',
      )
      for name in std.objectFields(managedRoles)
    };

    {
      dbOwner: dbOwner,
      objects: {
        managedRoleSecretStore:
          externalSecrets.store.new(name='gsm', gcpProject=p.gcpProject),
      } + roles + roleSecrets,
    },
}
