#import "PathUtils.h"

NSURL *KetSupportDirectoryURL(void)
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  return [[NSURL fileURLWithPath:paths[0]] URLByAppendingPathComponent:@"Ket"];
}

NSURL *CatalogsDirectoryURL(void)
{
  return [KetSupportDirectoryURL() URLByAppendingPathComponent:@"Catalogs"];
}

NSURL *CatalogDirectoryURLWithComiketID(NSString *comiketID)
{
  return [CatalogsDirectoryURL() URLByAppendingPathComponent:comiketID];
}

NSURL *CatalogDatabaseURLWithComiketID(NSString *comiketID)
{
  NSString *databaseName = [NSString stringWithFormat:@"%@.sqlite3", comiketID];
  return [CatalogDirectoryURLWithComiketID(comiketID) URLByAppendingPathComponent:databaseName];
}

NSURL *CircleCutArchiveURLWithComiketID(NSString *comiketID)
{
  NSString *archiveName = [NSString stringWithFormat:@"%@CUTH.CCZ", comiketID];
  return [CatalogDirectoryURLWithComiketID(comiketID) URLByAppendingPathComponent:archiveName];
}

BOOL EnsureDirectoryExistsAtURL(NSURL *URL)
{
  NSFileManager *manager = [NSFileManager defaultManager];
  BOOL isDirectory;
  BOOL exists = [manager fileExistsAtPath:URL.path isDirectory:&isDirectory];
  if (exists) return isDirectory;
  return [manager createDirectoryAtURL:URL withIntermediateDirectories:YES attributes:nil error:NULL];
}
