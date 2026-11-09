{
  resolve(p):
    local isString(value) = std.type(value) == 'string';
    local uniqueStrings(values) = std.objectFields({ [value]: true for value in values });
    local hasImageReference(ext) =
      std.type(ext) == 'object' &&
      std.objectHas(ext, 'image') &&
      std.type(ext.image) == 'object' &&
      std.objectHas(ext.image, 'reference');
    local normalizeDatabaseExtension(ext) =
      if isString(ext) then {
        ensure: 'present',
        name: ext,
      } else {
        ensure: 'present',
        name: ext.name,
      } + (if std.objectHas(ext, 'ensure') then { ensure: ext.ensure } else {}) +
      (if std.objectHas(ext, 'version') then { version: ext.version } else {});
    local normalizeClusterExtension(ext) =
      if isString(ext) then {
        name: ext,
      } else {
        [field]: ext[field]
        for field in std.objectFields(ext)
        if field != 'ensure'
      };
    local compatibilityDatabaseExtensions =
      [normalizeDatabaseExtension(ext) for ext in p.extensions];
    local clusterExtensions = [normalizeClusterExtension(ext) for ext in p.imageExtensions];
    local imageDatabaseExtensions =
      [normalizeDatabaseExtension(ext) for ext in p.imageExtensions];
    local databaseExtensions =
      compatibilityDatabaseExtensions + imageDatabaseExtensions;
    local clusterExtensionsNeedCatalog =
      [ext for ext in clusterExtensions if !hasImageReference(ext)];
    local compatibilityExtensionNames = [ext.name for ext in compatibilityDatabaseExtensions];
    local clusterExtensionNames = [ext.name for ext in clusterExtensions];
    local duplicateExtensionNames = std.setInter(
      std.set(compatibilityExtensionNames),
      std.set(clusterExtensionNames)
    );
    local effectiveImageCatalogRef =
      if p.imageCatalogRef != null then p.imageCatalogRef
      else p.defaultImageCatalogRef;

    assert std.type(p.extensions) == 'array' : 'extensions must be an array';
    assert std.type(p.imageExtensions) == 'array' : 'imageExtensions must be an array';
    assert std.type(p.defaultImageCatalogRef) == 'object' :
      'defaultImageCatalogRef must be an object';
    assert std.length([
      ext for ext in p.extensions
      if !isString(ext) && !std.objectHas(ext, 'name')
    ]) == 0 : 'extensions object entries must define name';
    assert std.length([
      ext for ext in p.imageExtensions
      if !isString(ext) && !std.objectHas(ext, 'name')
    ]) == 0 : 'imageExtensions object entries must define name';
    assert std.length(uniqueStrings(compatibilityExtensionNames)) ==
      std.length(compatibilityExtensionNames) :
      'extensions must not contain duplicate names';
    assert std.length(uniqueStrings(clusterExtensionNames)) ==
      std.length(clusterExtensionNames) :
      'imageExtensions must not contain duplicate names';
    assert std.length(duplicateExtensionNames) == 0 :
      'extensions and imageExtensions must not contain the same names: ' +
      std.join(', ', duplicateExtensionNames);
    assert effectiveImageCatalogRef != null ||
      std.length(clusterExtensionsNeedCatalog) == 0 :
      'Cluster extensions without imageCatalogRef must define image.reference or be overridden by imageExtensions entries that do';
    assert p.imageCatalogRef == null || std.type(p.imageCatalogRef) == 'object' :
      'imageCatalogRef must be an object when set';

    {
      clusterExtensions: clusterExtensions,
      databaseExtensions: databaseExtensions,
      effectiveImageCatalogRef: effectiveImageCatalogRef,
    },
}
