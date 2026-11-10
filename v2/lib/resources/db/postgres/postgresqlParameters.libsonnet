// Her skal det legges til ordentlige sqlparametere
local forProfile(profile, overrides={}) = {
  shared_buffers: std.toString(profile.reqMem * 1024 / 4 + 128) + 'MB',
  effective_cache_size: std.toString(profile.reqMem * 1024 * 3 / 4) + 'MB',
  maintenance_work_mem: std.toString(profile.reqMem * 64) + 'MB',
  autovacuum_work_mem: std.toString(profile.reqMem * 16) + 'MB',
} + overrides;

{
  forProfile: forProfile,
}
