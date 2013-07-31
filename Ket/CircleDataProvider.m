#import "CircleDataProvider.h"

#import "CatalogDatabase.h"
#import "Circle.h"
#import "CircleCollection.h"
#import "CircleCutArchive.h"
#import "PathUtils.h"

@interface CircleDataProvider ()

// XXX: remove
@property (nonatomic) CatalogDatabase *database;
@property (nonatomic) CircleCutArchive *archive;

@property (nonatomic, readwrite) NSUInteger comiketNo;

@end

@implementation CircleDataProvider

- (instancetype)initWithComiketNo:(NSUInteger)comiketNo
{
  self = [super init];
  if (!self) return nil;

  self.comiketNo = comiketNo;

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
  return self.database.pageSet.count * 2;
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

- (NSString *)blockNameForID:(NSInteger)blockID
{
  return [self.database blockNameForID:blockID];
}

- (NSImage *)imageForCircle:(Circle *)circle
{
  return [self.archive imageForCircle:circle];
}

#pragma mark Accessors

- (NSSize)cutSize
{
  return self.archive.cutSize;
}

- (NSUInteger)numberOfCutsInRow
{
  return self.database.numberOfCutsInRow;
}

- (NSUInteger)numberOfCutsInColumn
{
  return self.database.numberOfCutsInColumn;
}

- (NSIndexSet *)pageSet
{
  return self.database.pageSet;
}

- (CircleCollection *)circleCollectionForPage:(NSUInteger)page
{
  return [self.database circleCollectionForPage:page];
}

@end
