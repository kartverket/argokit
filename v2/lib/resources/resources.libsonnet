local roles = import './roles.libsonnet';
local routing = import './routing.libsonnet';
local azureAdApplication = import 'azureAdApplication.libsonnet';
{
  azureAdApplication: azureAdApplication,
  routing: routing,
  roles: roles,
}
