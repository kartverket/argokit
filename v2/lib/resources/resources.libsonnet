local externalSecrets = import './externalSecrets.libsonnet';
local routing = import './routing.libsonnet';
local azureAdApplication = import 'azureAdApplication.libsonnet';
{
  azureAdApplication: azureAdApplication,
  routing: routing,
  externalSecrets: externalSecrets,
}
