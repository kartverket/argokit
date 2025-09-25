local argokit = import '../v2/jsonnet/argokit.libsonnet';
local configHooks = import '../v2/lib/configHooks.libsonnet';


local app = argokit.application.new('test')
            + argokit.application.withVariable('MSG', 'hello')
;


local appAndObj = argokit.appAndObjects.AppAndObjects {
  application:: app,
  objects:: [],
};


local config = {
  isSkipJob: true,
};


//appAndObj + testHook(appAndObj, config)


// std.foldl(
//   function(ap, hook) ap + hook(ap, config),
//   configHooks,
//   appAndObj
// )


appAndObj
