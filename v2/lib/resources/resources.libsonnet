local externalSecrets = import './externalSecrets.libsonnet';
local k8s = import './k8s/k8s.libsonnet';
local db = import './db/db.libsonnet';
local routing = import './routing.libsonnet';
local azureAdApplication = import 'azureAdApplication.libsonnet';

{
  azureAdApplication: azureAdApplication,
  routing: routing,
  externalSecrets: externalSecrets,
  k8s: k8s,
  db: db,
}
