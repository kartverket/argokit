local k8s = import './k8s/k8s.libsonnet';
local rolebinding = import './rolebinding.libsonnet';
local routing = import './routing.libsonnet';
local azureAdApplication = import 'azureAdApplication.libsonnet';
{
  azureAdApplication: azureAdApplication,
  routing: routing,
  rolebinding: rolebinding,
  k8s: k8s,
}
