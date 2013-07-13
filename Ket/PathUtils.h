NSString *ComiketIDFromComiketNo(NSUInteger comiketNo);
NSURL *KetSupportDirectoryURL(void);
NSURL *CatalogsDirectoryURL(void);
NSURL *CatalogDirectoryURLWithComiketID(NSString *comiketID);
NSURL *CatalogDatabaseURLWithComiketID(NSString *comiketID);
NSURL *CircleCutArchiveURLWithComiketID(NSString *comiketID);
BOOL EnsureDirectoryExistsAtURL(NSURL *URL);
