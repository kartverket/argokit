{
  // extend appAndObjects structure with additional objects
  withAdditionalObjects(items): {
    objects+: if std.isArray(items) then items else [items],
  },
}
