local utils = import '../../../internal/utils.libsonnet';
local v = import '../../../internal/validation.libsonnet';
{
  new():: {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'RoleBinding',
    metadata: {
      // will be overridden on withUsers or withNamespaceAdminGroup call on this object
      name: error 'incomplete rolebinding: you need to extend the rolebinging with, +withUsers() or +withNamespaceAdminGroup()',

    },
    subjects: [],
    roleRef: {
      kind: 'ClusterRole',
      name: 'cluster-admin',
      apiGroup: 'rbac.authorization.k8s.io',
    },
  } + utils.withArgokitVersionLabel('v2'),

  withUsers(users)::
    v.array(users, 'users') +
    {
      subjects+: [
        {
          apiGroup: 'rbac.authorization.k8s.io',
          kind: 'User',
          name: u,
        }
        for u in users
      ],
      metadata+: {
        name: 'team-admin',
        annotations: {
          description: 'Binds cluster-admin to every member and relevant SAs within a product. Allows all subjects to have full rights within their namespace. Usually reserved for dev/sandbox.',
        },
      },
    },
  withNamespaceAdminGroup(groupName)::
    v.string(groupName, 'groupName') +
    {
      subjects+: [
        {
          apiGroup: 'rbac.authorization.k8s.io',
          kind: 'Group',
          name: groupName,
        },
      ],
      metadata+: {
        name: 'namespace-admin',
        annotations: {
          description: 'Binds cluster-admin to the team AD/Google Group. Allows all subjects to have full rights within their namespace. Reserved for dev/sandbox.',
        },
      },
    },
}
