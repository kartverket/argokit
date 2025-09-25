local argokit = import '../v2/jsonnet/argokit.libsonnet';

local env = {
  withTestValue(value):: {
    spec+: {
      testVal: value,
    },
  },
};

local hooks = {
  /*
  * if the given application is a skip job,
  * wrap the spec object in a container object
  */

  specHook(conf)::
    if conf.isAppAndObjects then
      {
        application+:
          local s = self.spec;
          if conf.isSkipJob then
            { container+: { spec+: s } }
          else
            { spec+: s },
      }
    else
      if conf.isSkipJob then
        {
          local s = self.spec,
          container+: { spec+: s },
        }
      else {},
};


local templates = {
  AppAndObjects:: {
    apiVersion: 'v1',
    kind: 'List',
    local appConfig = {
      isSkipJob: false,
      isAppAndObjects: true,
    },

    local result = std.foldl(
      function(ap, hook) ap + hook(appConfig),
      [hooks.specHook],
      self
    ),

    items: [result.application],
    spec:: {},
  },
};

local appAndObj = templates.AppAndObjects {
  application:: {
    apiVersion: 'skiperator.kartverket.no/v1alpha1',
    kind: 'Application',
    metadata: {
      name: 'testapp',
    },
  },
  objects:: [],
};

appAndObj
+ env.withTestValue('test-val')
