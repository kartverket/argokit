{
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
        spec:: {},
      }
    else
      if conf.isSkipJob then
        {
          local s = self.spec,
          container+: { spec+: s },
          spec:: {},
        }
      else {},
}
