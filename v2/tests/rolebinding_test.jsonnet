local argokit = import '../jsonnet/argokit.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

local label = 'rolebinding ';

// test data
local testUsers = [
  'example1@kartverket.no',
  'example2@kartverket.no',
  'example3@kartverket.no',
];
local testGroupName = 'test-group';


// build test objects
local rbTeam =
  argokit.rolebinding.new()
  + argokit.rolebinding.withUsers(testUsers);

local rbAdmin =
  argokit.rolebinding.new()
  + argokit.rolebinding.withNamespaceAdminGroup(testGroupName);


// test cases for resourcebinding team admin

test.new(std.thisFile)
+ test.case.new(
  name=label + 'metadata name is team admin',
  test=test.expect.eqDiff(
    actual=rbTeam.metadata.name,
    expected='team-admin',
  )
)

+ test.case.new(
  name=label + 'subjects kind is User',
  test=test.expect.eqDiff(
    actual=std.all(std.map(function(x) x.kind == 'User', rbTeam.subjects)),
    expected=true,
  )
)

+ test.case.new(
  name=label + 'subject names match',
  test=test.expect.eqDiff(
    actual=std.map(function(x) x.name, rbTeam.subjects),
    expected=testUsers,
  )
)

// test cases for resourcebinding namespace admin group

+ test.case.new(
  name=label + 'metadata name is namespace admin',
  test=test.expect.eqDiff(
    actual=rbAdmin.metadata.name,
    expected='namespace-admin',
  )
)

+ test.case.new(
  name=label + 'subjects kind is Group',
  test=test.expect.eqDiff(
    actual=std.all(std.map(function(x) x.kind == 'Group', rbAdmin.subjects)),
    expected=true,
  )
)

+ test.case.new(
  name=label + 'group name is correct',
  test=test.expect.eqDiff(
    actual=std.map(function(x) x.name, rbAdmin.subjects),
    expected=[testGroupName],
  )
)
