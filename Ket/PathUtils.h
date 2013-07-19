// Returns "Cxxx" where xxx is a given Comiket number, zero-padded
//
// Comiket ID is the canonical representation of Comiket number. Prefer it to
// Comiket name for file name etc.
NSString *ComiketIDFromComiketNo(NSUInteger comiketNo);

// Returns "Cxx" where xx is a given Comiket number, two- or three-digit
//
// Comiket name is a conventional representation of Comiket number. Prefer it to
// Comiket ID for UI use.
NSString *ComiketNameFromComiketNo(NSUInteger comiketNo);

// Returns a Comiket number by parsing a given Comiket name or Comiket ID
NSUInteger ComiketNoFromString(NSString *comiketNameOrID);

// Returns a URL that points to "<Home directory>/Application Support/Ket"
NSURL *KetSupportDirectoryURL(void);

// Returns a URL that points to "<Ket support directory>/Catalogs"
NSURL *CatalogsDirectoryURL(void);

// Returns a URL that points to "<Catalogs directory>/<Comiket ID>"
NSURL *CatalogDirectoryURLWithComiketNo(NSUInteger comiketNo);

// Returns a URL that points to "<Catalog directory>/<Comiket ID>.sqlite3"
NSURL *CatalogDatabaseURLWithComiketNo(NSUInteger comiketNo);

// Returns a URL that points to "<Catalog directory>/<Comiket ID>CUTH.CCZ"
NSURL *CircleCutArchiveURLWithComiketNo(NSUInteger comiketNo);

// Ensure a directory exists at a given URL
//
// This method creates a directory at the URL if needed. Returns YES if there
// already is a directory or created one successfully. Otherwise, NO.
BOOL EnsureDirectoryExistsAtURL(NSURL *URL);
