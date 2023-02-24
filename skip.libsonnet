{
    Roles: {
        local this = self,
        members:: error "image required",

        apiVersion: 'rbac.authorization.k8s.io/v1',
        kind: 'RoleBinding',
        metadata: {
            name: 'team-admin',
            annotations: {
                description: 'Binds cluster-admin to every member and relevant SAs within a product. Allows all subjects to have full rights within their namespace. Usually reserved for dev/sandbox.',
            },
        },
        subjects: [
            {
            apiGroup: 'rbac.authorization.k8s.io',
            kind: 'User',
            name: user,
            } for user in this.members
        ],
        roleRef: {
            kind: 'ClusterRole',
            name: 'cluster-admin',
            apiGroup: 'rbac.authorization.k8s.io',
        },
    },
    Secret(name): {
        // TODO make secrets and secrets store easy
    },
    Application(name): {
        apiVersion: 'skiperator.kartverket.no/v1alpha1',
        kind: 'Application',
        metadata: {
            name: name,
        },
    }
}