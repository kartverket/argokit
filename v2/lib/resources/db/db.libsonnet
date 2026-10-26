local dbOnprem = import './dbOnprem.libsonnet';
local dbOnpremRestore = import './dbOnpremRestore.libsonnet';

{
  dbOnprem: dbOnprem,
  dbOnpremRestore: dbOnpremRestore,
}
