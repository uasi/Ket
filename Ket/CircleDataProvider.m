#import "CircleDataProvider.h"

#import "CatalogDatabase.h"
#import "Circle.h"
#import "CircleCollection.h"
#import "CircleCutArchive.h"
#import "PathUtils.h"

@interface CircleDataProvider ()

@property (nonatomic) CatalogDatabase *database;
@property (nonatomic) CircleCutArchive *archive;

@end

@implementation CircleDataProvider

- (instancetype)initWithComiketNo:(NSUInteger)comiketNo
{
  self = [super init];
  if (!self) return nil;

  NSURL *databaseURL = CatalogDatabaseURLWithComiketNo(comiketNo);
  self.database = [[CatalogDatabase alloc] initWithURL:databaseURL];
  if (!self.database) return nil;

  NSURL *archiveURL = CircleCutArchiveURLWithComiketNo(comiketNo);
  self.archive = [[CircleCutArchive alloc] initWithURL:archiveURL];
  if (!self.archive) return nil;

  return self;[[NSFileManager defaultManager] fileExistsAtPath:[archiveURL path]];
}

- (NSInteger)numberOfRows
{
  return self.database.pageNoIndexSet.count * 2;
}

- (CircleCollection *)circleCollectionForRow:(NSInteger)row
{
  if ([self isGroupRow:row]) return nil;
  return [self.database circleCollectionForPage:[self pageForRow:row]];
}

- (NSString *)stringValueForGroupRow:(NSInteger)row
{
  if (![self isGroupRow:row]) return nil;
  return [NSString stringWithFormat:@"Page %ld", (long)[self pageForRow:row]];
}

- (BOOL)isGroupRow:(NSInteger)row
{
  return row % 2 == 0;
}

- (NSInteger)pageForRow:(NSInteger)row
{
  return row / 2;
}

- (NSInteger)rowForPage:(NSInteger)page
{
  return page * 2;
}

#pragma mark Accessors

- (CatalogDatabase *)catalogDatabase
{
  return self.database;
}

- (CircleCutArchive *)circleCutArchive
{
  return self.archive;
}

@end
