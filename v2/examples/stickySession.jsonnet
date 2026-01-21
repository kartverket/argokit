local argokit = import '../jsonnet/argokit.libsonnet';
local application = argokit.appAndObjects.application;

// Example: Application with sticky sessions enabled (default settings, no path)
// This creates an Istio DestinationRule that ensures requests from the same client
// are routed to the same pod using cookie-based consistent hashing

application.new('my-app', 'my-image:1.0', 8080)
+ application.withStickySession()

// With custom cookie settings (like the aal-register example):
// application.new('my-app', 'my-image:1.0', 8080)
// + application.withStickySession(cookieName='MY-SESSION', cookieTtl='1800s')

// With path specified:
// application.new('my-app', 'my-image:1.0', 8080)
// + application.withStickySession(cookieName='MY-SESSION', cookiePath='/api', cookieTtl='3600s')
