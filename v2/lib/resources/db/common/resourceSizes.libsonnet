local profiles = {
  S:  { reqMem: 4,  reqCpu: 375,  limMem: 4 },
  M:  { reqMem: 8,  reqCpu: 750, limMem: 8 },
  L:  { reqMem: 16,  reqCpu: 1500, limMem: 16 },
  XL: { reqMem: 32, reqCpu: 3000, limMem: 32 },
};

local restoreProfiles = {
  S:  { reqMem: 4,  reqCpu: 375,  limMem: 4 },
  M:  { reqMem: 8,  reqCpu: 750, limMem: 8 },
  L:  { reqMem: 16,  reqCpu: 1000, limMem: 16 },
  XL: { reqMem: 32, reqCpu: 3000, limMem: 32 },
};

{
  profiles: profiles,
  restoreProfiles: restoreProfiles,
  get(size, profileSet='onprem'):
    local selectedProfiles =
      if profileSet == 'restore' then restoreProfiles else profiles;
    assert std.member(['onprem', 'restore'], profileSet) :
      'Invalid resource profile set: ' + profileSet;
    assert std.type(size) == 'string' && std.objectHas(selectedProfiles, size) :
      'Invalid t-shirt size: ' + std.toString(size);
    selectedProfiles[size],
}
