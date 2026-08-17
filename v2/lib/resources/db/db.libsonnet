local dbOnprem = import './dbOnprem.libsonnet';
local dbOnpremrestoretest = import './dbOnpremrestoretest.libsonnet';

{
  dbOnprem: dbOnprem,
  dbOnpremrestoretest: dbOnpremrestoretest,
}
