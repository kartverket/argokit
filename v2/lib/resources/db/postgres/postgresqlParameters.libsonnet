// Her skal det legges til ordentlige sqlparametere
local forProfile(profile, overrides={}) = {
  shared_buffers: std.toString(profile.reqMem * 1024 / 4 + 128) + 'MB',
} + overrides;

{
  forProfile: forProfile,
}
