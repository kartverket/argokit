local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';
local application = argokit.appAndObjects.application;

local testConfig = {
  PORT: 3000,
  TIMEOUT: 100,
};

local configMap = argokit.k8s.configMap.new(
  name='regular',
  data=testConfig,
);

local hashedConfigMap = argokit.k8s.configMap.new(
  name='hashed',
  data=testConfig,
  addHashToName=true,
);


// app and objcet test data

local appAndObjectsconfigMapAsEnv =
  application.new('application')
  + application.withConfigMapAsEnv(name='port', data={ PORT: 3333 });

local appAndObjectsconfigMapAsMount =
  application.new('application')
  + application.withConfigMapAsMount(name='port', mountPath='port-as-file', data={ PORT: 3333 });


local label = 'Test ConfigMaps ';
test.new(std.thisFile)

+ test.case.new(
  name='Kind is ConfigMap',
  test=test.expect.eqDiff(
    actual=configMap.kind,
    expected='ConfigMap'
  )
)

+ test.case.new(
  name='Data is set',
  test=test.expect.eqDiff(
    actual=configMap.data,
    expected=testConfig,
  )
)

+ test.case.new(
  name='Name is set',
  test=test.expect.eqDiff(
    actual=configMap.metadata.name,
    expected='regular-configmap',
  )
)

+ test.case.new(
  name='Hashed configmap adds old name as label',
  test=test.expect.eqDiff(
    actual=hashedConfigMap.metadata.labels.name,
    expected='hashed-configmap',
  )
)

+ test.case.new(
  name='Hashed configmap hashes name',
  test=test.expect.eqDiff(
    actual={
      orgName: hashedConfigMap.metadata.labels.name,
      hashedName:: hashedConfigMap.metadata.name,
      len: std.length(self.hashedName),
    },
    expected={
      orgName: 'hashed-configmap',
      len: std.length(self.orgName) + 8,  // 7 char hash and '-'
    },
  )
)

// app and objects test cases
// withConfigMapAsEnv

+ test.case.new(
  name='withConfigMapAsEnv creates valid configMap resource',
  test=test.expect.eqDiff(
    actual=appAndObjectsconfigMapAsEnv.items[1].kind,
    expected='ConfigMap'
  )
)

+ test.case.new(
  name='withConfigMapAsEnv sets correct env',
  test=test.expect.eqDiff(
    actual=appAndObjectsconfigMapAsEnv.items[0].spec.envFrom[0].configMap,
    expected=appAndObjectsconfigMapAsEnv.items[1].metadata.name
  )
)

// withConfigMapAsMount
+ test.case.new(
  name='withConfigMapAsMount creates valid configMap resource',
  test=test.expect.eqDiff(
    actual=appAndObjectsconfigMapAsMount.items[1].kind,
    expected='ConfigMap'
  )
)

+ test.case.new(
  name='withConfigMapAsMount sets correct env',
  test=test.expect.eqDiff(
    actual=appAndObjectsconfigMapAsMount.items[0].spec.filesFrom[0],
    expected={
      configMap: appAndObjectsconfigMapAsEnv.items[1].metadata.name,
      mountPath: 'port-as-file',
    }
  )
)
