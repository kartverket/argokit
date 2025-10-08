local rolebinding = import './rolebinding.libsonnet';
local routing = import './routing.libsonnet';
local azureAdApplication = import 'azureAdApplication.libsonnet';
{
  azureAdApplication: azureAdApplication,
  routing: routing,
  rolebinding: rolebinding,
}
