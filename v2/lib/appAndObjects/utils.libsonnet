{
  // extend appAndObjects structure with additional objects
  withObjects(items): {
    objects+: if std.isArray(items) then items else [items],
  },
}
