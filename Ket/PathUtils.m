#import "PathUtils.h"

NSString *ComiketIDFromComiketNo(NSUInteger comiketNo)
{
  NSCAssert(1 <= comiketNo && comiketNo <= 999, @"comiketNo must be in [1, 999]");
  return [NSString stringWithFormat:@"C%03d", (int)comiketNo];
}

NSString *ComiketNameFromComiketNo(NSUInteger comiketNo)
{
  NSCAssert(1 <= comiketNo && comiketNo <= 999, @"comiketNo must be in [1, 999]");
  return [NSString stringWithFormat:@"C%02d", (int)comiketNo];
}

NSUInteger ComiketNoFromString(NSString *comiketNameOrID)
{
  NSInteger comiketNo;
  NSScanner *scanner = [NSScanner scannerWithString:comiketNameOrID];
  scanner.charactersToBeSkipped = [NSCharacterSet characterSetWithCharactersInString:@"Cc"];
  BOOL ok = [scanner scanInteger:&comiketNo];
  return (NSUInteger)(ok ? comiketNo : 0);
}

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
