#import "CircleDataProvider.h"

#import "CatalogDatabase.h"
#import "CatalogFilter.h"
#import "CatalogPerspective.h"
#import "Checklist.h"
#import "Circle.h"
#import "CircleCollection.h"
#import "CircleCutArchive.h"
#import "PathUtils.h"

@interface CircleDataProvider ()

@property (nonatomic, readwrite) NSUInteger comiketNo;
@property (nonatomic, readwrite) Checklist *checklist;
@property (nonatomic, readwrite) CatalogDatabase *database;
@property (nonatomic, readwrite) RACSignal *dataDidChangeSignal;

@property (nonatomic) CatalogPerspective *perspective;
@property (nonatomic) CircleCutArchive *archive;

@property (nonatomic) NSCache *circleCollectionCache;
@property (nonatomic, readonly) NSCache *sharedCircleCutCache;

@end

@implementation CircleDataProvider

@synthesize filter = _filter;

- (instancetype)initWithChecklist:(Checklist *)checklist
{
  NSAssert(checklist, @"checklist must not be nil");

  self = [super init];
  if (!self) return nil;

  self.checklist = checklist;
  self.comiketNo = checklist.comiketNo;

  NSURL *databaseURL = CatalogDatabaseURLWithComiketNo(checklist.comiketNo);
  self.database = [[CatalogDatabase alloc] initWithURL:databaseURL];
  if (!self.database) return nil;

  self.perspective = [CatalogPerspective perspectiveWithDatabase:self.database];

  NSURL *archiveURL = CircleCutArchiveURLWithComiketNo(checklist.comiketNo);
  self.archive = [[CircleCutArchive alloc] initWithURL:archiveURL];
  if (!self.archive) return nil;

  self.circleCollectionCache = [[NSCache alloc] init];

  self.dataDidChangeSignal = [RACSubject subject];

  return self;
}

- (NSInteger)numberOfRows
{
  return MAX(2, self.perspective.numberOfCircleCollections * 2);
}

- (CircleCollection *)circleCollectionForRow:(NSInteger)row
{
  if ([self isGroupRow:row]) return nil;

  CircleCollection *collection = [self.circleCollectionCache objectForKey:@(row)];
  if (collection) return collection;

  if (self.perspective.numberOfCircleCollections > 0) {
    collection = [self.perspective circleCollectionAtIndex:[self pageIndexForRow:row]];
  }
  else {
    collection = [CircleCollection emptyCircleCollectionWithMaxCount:self.perspective.numberOfCirclesPerCollection];
  }
  [self.circleCollectionCache setObject:collection forKey:@(row)];
  return collection;
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
  NSImage *image = [self.sharedCircleCutCache objectForKey:@(circle.globalID)];
  if (image) return image;

  if ([circle isEqual:[Circle emptyCircle]]) {
    image = [NSImage imageNamed:@"Placeholder210x300"];
  }
  else {
    image = [self.archive imageForCircle:circle];
  }
  [self.sharedCircleCutCache setObject:image forKey:@(circle.globalID)];
  return image;
}

- (void)filterWithString:(NSString *)string
{
  self.filter = [CatalogFilter filterWithDatabase:self.database checklist:self.checklist string:string];
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

- (CatalogFilter *)filter
{
  return _filter;
}

- (void)setFilter:(CatalogFilter *)filter
{
  self.perspective = [CatalogPerspective perspectiveWithDatabase:self.database filter:filter];
  [self.circleCollectionCache removeAllObjects];
  [(RACSubject *)self.dataDidChangeSignal sendNext:nil];
  _filter = filter;
}

- (NSCache *)sharedCircleCutCache
{
  static NSCache *cache;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    cache = [[NSCache alloc] init];
  });
  return cache;
}

@end
