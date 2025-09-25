local skipJobHook(a, conf) =
  if conf.isSkipJob then
    {
      application+: {
        container+: {
          spec: a.application.spec,
        },
        spec:: '',
      },
    }
  else
    {
      application+: {
        spec: a.application.spec,
      },
    };


[skipJobHook]
