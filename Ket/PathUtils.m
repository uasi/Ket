#import "PathUtils.h"

#import "ConversionUtils.h"
#import "NSRegularExpression+Extensions.h"

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
