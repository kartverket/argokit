local argokit = import '../jsonnet/argokit.libsonnet';

argokit.routing.new('myapp-routing',
                    'myhostname',
                    [
                      argokit.routing.route(pathPrefix='/web', targetApp='myapp-web', rewriteUri=false),
                      argokit.routing.route(pathPrefix='/api', targetApp='myapp-api', rewriteUri=false),
                    ])
