#import "PathUtils.h"

#import "NSRegularExpression+Extensions.h"

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

NSArray *CatalogDirectoryURLs(void)
{
  NSArray *URLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:CatalogsDirectoryURL() includingPropertiesForKeys:@[NSURLIsDirectoryKey] options:0 error:NULL];
  if (!URLs) return nil;
  NSMutableArray *catalogURLs = [NSMutableArray array];
  for (NSURL *URL in URLs) {
    NSNumber *isDirectory;
    [URL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
    BOOL hasCorrectName = [NSRegularExpression testString:URL.lastPathComponent withPattern:@"^C\\d{2,3}$"];
    if (isDirectory.boolValue && hasCorrectName) {
      [catalogURLs addObject:URL];
    }
  }
  NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastPathComponent" ascending:NO selector:@selector(localizedStandardCompare:)];
  return [catalogURLs sortedArrayUsingDescriptors:@[descriptor]];
}

NSURL *CatalogDirectoryURLWithComiketNo(NSUInteger comiketNo)
{
  return [CatalogsDirectoryURL() URLByAppendingPathComponent:ComiketIDFromComiketNo(comiketNo)];
}

NSURL *CatalogDatabaseURLWithComiketNo(NSUInteger comiketNo)
{
  NSString *databaseName = [NSString stringWithFormat:@"%@.sqlite3", ComiketIDFromComiketNo(comiketNo)];
  return [CatalogDirectoryURLWithComiketNo(comiketNo) URLByAppendingPathComponent:databaseName];
}

NSURL *CircleCutArchiveURLWithComiketNo(NSUInteger comiketNo)
{
  NSString *archiveName = [NSString stringWithFormat:@"%@CUTH.CCZ", ComiketIDFromComiketNo(comiketNo)];
  return [CatalogDirectoryURLWithComiketNo(comiketNo) URLByAppendingPathComponent:archiveName];
}

BOOL EnsureDirectoryExistsAtURL(NSURL *URL)
{
  NSFileManager *manager = [NSFileManager defaultManager];
  BOOL isDirectory;
  BOOL exists = [manager fileExistsAtPath:URL.path isDirectory:&isDirectory];
  if (exists) return isDirectory;
  return [manager createDirectoryAtURL:URL withIntermediateDirectories:YES attributes:nil error:NULL];
}
