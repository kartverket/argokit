local profiles = {
  S:  { reqMem: 5,  reqCpu: 500, limCpu: 500, limMem: 5 },
  M:  { reqMem: 8,  reqCpu: 750, limCpu: 750, limMem: 8 },
  L:  { reqMem: 16, reqCpu: 1500, limCpu: 1500, limMem: 16 },
  XL: { reqMem: 32, reqCpu: 3000, limCpu: 3000, limMem: 32 },
};

{
  profiles: profiles,
  get(size):
    assert std.type(size) == 'string' && std.objectHas(profiles, size) :
      'Invalid t-shirt size: ' + std.toString(size);
    profiles[size],
}
