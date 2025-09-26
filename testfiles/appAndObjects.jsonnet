local argokit = import '../v2/jsonnet/argokit.libsonnet';


/*
 * En hook som flytter omstrukturerer app objektet basert
 på om det bruker AppAndObject struktur, eller en "enkel"
 applikasjon struktur. Det Sjekker også om det er en
 skip job, for å evt. wrappe spec i et container objekt.
 */
local hooks = {
  specHook(conf)::
    if conf.isAppAndObjects then
      {
        application+:
          local s = self.spec;
          if conf.isSkipJob then
            { container+: { spec+: s }, spec:: {} }
          else
            { spec+: s },
      }
    else
      if conf.isSkipJob then
        {
          local s = self.spec,
          container+: { spec+: s },
          spec:: {},
        }
      else {},
};

/*
 * App and object template basert på Heimdal sin app and objects
 */
local templates = {
  AppAndObjects:: {
    apiVersion: 'v1',
    kind: 'List',

    local isSkipJob = self.application.kind == 'SKIPJob',

    local appConfig = {
      isSkipJob: isSkipJob,
      isAppAndObjects: true,
    },

    local result = std.foldl(
      function(ap, hook) ap + hook(appConfig),
      [hooks.specHook],
      self
    ),

    items: std.sort([result.application] + result.objects, keyF=function(x) x.metadata.name),
    spec:: {},
  },
};


/*
 * Wrapper funksjoner for å slippe å bruke template direkte
*/
local constructors = {
  application: {
    newAppAndObjects(name):
      templates.AppAndObjects {
        application:: {
          apiVersion: 'skiperator.kartverket.no/v1alpha1',
          kind: 'Application',
          metadata: {
            name: name,
          },
        },
        objects:: [],
      },
    new(name):
      local app = {
        apiVersion: 'skiperator.kartverket.no/v1alpha1',
        kind: 'Application',
        metadata: {
          name: name,
        },
      };
      app,
  },
  skipJob: {
    newAppAndObjects(name):
      templates.AppAndObjects {
        application:: {
          apiVersion: 'skiperator.kartverket.no/v1alpha1',
          kind: 'SKIPJob',
          metadata: {
            name: name,
          },
        },
        objects:: [],
      },
    new(name):
      local job = {
        apiVersion: 'skiperator.kartverket.no/v1alpha1',
        kind: 'SKIPJob',
        metadata: {
          name: name,
        },
      };
      self.enableArgokit(job),
    enableArgokit(job):
      local c = {
        isSkipJob: job.kind == 'SKIPJob',
        isAppAndObjects: false,
      };
      std.foldl(
        function(ap, hook) ap + hook(c),
        [hooks.specHook],
        job
      ),
  },
};


// ====== TEST CASE - ARGOKIT APPLICATION ======

local skipApp = {
  apiVersion: 'skiperator.kartverket.no/v1alpha1',
  kind: 'Application',
  metadata: {
    name: 'test',
  },
  spec: {
    port: 8080,
    image: 'test-image',
  },
};

local skipJob = {
  apiVersion: 'skiperator.kartverket.no/v1alpha1',
  kind: 'SKIPJob',
  metadata: {
    name: 'test-job',
  },
};


/* [1] Using AppAndObjects */
//constructors.application.newAppAndObjects('test-app')

/* [2] Non-AppAndObjects app with constructors */
//constructors.application.new('test-app')

/* [3] Using bare bones app definition */
//skipApp


// ====== TEST CASE - ARGOKIT SKIP JOB ======


/* [1] Using AppAndObjects */
// constructors.skipJob.newAppAndObjects('test-job')

/* [2] Non-AppAndObjects app with constructors */
// constructors.skipJob.new('test-job')

/* [3] Using bare bones app definition */

constructors.skipJob.enableArgokit(skipJob)


// add postgres access policies
+ argokit.application.withOutboundPostgres('localhost', '10.0.0.1')
+ argokit.application.withVariable('CLIENT_SECRET', 'abc123')
