local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';


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
  hashed=true,
);

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
      len: std.length(self.orgName) + 8,  // 7 char has and '-'
    },
  )
)
