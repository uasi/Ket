#import "CircleDataProvider.h"

#import "CatalogDatabase.h"
#import "CatalogPerspective.h"
#import "Circle.h"
#import "CircleCollection.h"
#import "CircleCutArchive.h"
#import "PathUtils.h"

@interface CircleDataProvider ()

@property (nonatomic) CatalogDatabase *database;
@property (nonatomic) CatalogPerspective *perspective;
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

  self.perspective = [self.database perspective];

  NSURL *archiveURL = CircleCutArchiveURLWithComiketNo(comiketNo);
  self.archive = [[CircleCutArchive alloc] initWithURL:archiveURL];
  if (!self.archive) return nil;

  return self;[[NSFileManager defaultManager] fileExistsAtPath:[archiveURL path]];
}

- (NSInteger)numberOfRows
{
  return self.perspective.numberOfCircleCollections * 2;
}

- (CircleCollection *)circleCollectionForRow:(NSInteger)row
{
  if ([self isGroupRow:row]) return nil;
  return [self.perspective circleCollectionAtIndex:[self pageIndexForRow:row]];
}

- (NSString *)stringValueForGroupRow:(NSInteger)row
{
  if (![self isGroupRow:row]) return nil;
  return [NSString stringWithFormat:@"Page %lu", (unsigned long)[self.perspective pageAtIndex:[self pageIndexForRow:row]]];
}

- (BOOL)isGroupRow:(NSInteger)row
{
  return row % 2 == 0;
}

- (NSInteger)pageIndexForRow:(NSInteger)row
{
  return row / 2;
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

@end
