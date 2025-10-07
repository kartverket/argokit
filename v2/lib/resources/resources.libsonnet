local routing = import './routing.libsonnet';
local secrets = import './secrets.libsonnet';
local azureAdApplication = import 'azureAdApplication.libsonnet';
{
  azureAdApplication: azureAdApplication,
  routing: routing,
  secrets: secrets,
}
