local externalSecrets = import './externalSecrets.libsonnet';
local rolebinding = import './rolebinding.libsonnet';
local routing = import './routing.libsonnet';
local azureAdApplication = import 'azureAdApplication.libsonnet';
{
  azureAdApplication: azureAdApplication,
  routing: routing,
  externalSecrets: externalSecrets,
  rolebinding: rolebinding,
}
