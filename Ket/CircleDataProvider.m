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

@property (nonatomic, readwrite) RACSignal *dataDidChangeSignal;
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

  self.perspective = [CatalogPerspective perspectiveWithDatabase:self.database];

  NSURL *archiveURL = CircleCutArchiveURLWithComiketNo(comiketNo);
  self.archive = [[CircleCutArchive alloc] initWithURL:archiveURL];
  if (!self.archive) return nil;

  self.dataDidChangeSignal = [RACSubject subject];

  return self;
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
  return [self circleCollectionForRow:row + 1].summary;
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
  if ([circle isEqual:[Circle emptyCircle]]) {
    return [NSImage imageNamed:@"Placeholder210x300"];
  }
  else {
    return [self.archive imageForCircle:circle];
  }
}

- (void)filterUsingString:(NSString *)string
{
  if ([string isEqualToString:@""]) {
    self.perspective = [CatalogPerspective perspectiveWithDatabase:self.database];
  }
  else {
    self.perspective = [CatalogPerspective perspectiveWithDatabase:self.database filter:string];
  }

  [(RACSubject *)self.dataDidChangeSignal sendNext:nil];
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

@end
