// Returns a URL that points to "<Home directory>/Application Support/Ket"
NSURL *KetSupportDirectoryURL(void);

// Returns a URL that points to "<Ket support directory>/Catalogs"
NSURL *CatalogsDirectoryURL(void);

// Returns an array of available catalog directory URLs
//
// URLs are sorted in descending order (latest comes first).
NSArray *CatalogDirectoryURLs(void);

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
