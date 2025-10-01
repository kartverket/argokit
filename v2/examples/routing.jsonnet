local argokit = import '../jsonnet/argokit.libsonnet';

argokit.routing.new('myapp-routing', 'myhostname', redirectToHTTPS=true)
+ argokit.routing.withRoute(pathPrefix='/web', targetApp='myapp-web', rewriteUri=false)
+ argokit.routing.withRoute(pathPrefix='/api', targetApp='myapp-api', rewriteUri=false, port=8080)
