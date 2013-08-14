#import "CatalogPerspective.h"

#import "CatalogDatabase.h"
#import "CatalogFilter.h"
#import "Circle.h"
#import "CircleCollection.h"
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseAdditions.h>

#define ABSTRACT_METHOD NSAssert(NO, @"abstract method %s is called", __func__)

@interface CatalogDatabase (CatalogPerspective_Private)

@property (nonatomic, readonly) FMDatabase *database;

@end

@interface CatalogPerspective ()

@property (nonatomic) CatalogDatabase *database;
@property (nonatomic, weak) FMDatabase *fmDatabase;
@property (nonatomic) CatalogFilter *filter;

@property (nonatomic, readonly) NSString *viewName;

@end

#pragma mark -
#pragma mark CatalogPerspectiveDefault (Concrete Subclass)

@interface CatalogPerspectiveDefault : CatalogPerspective

@end

@implementation CatalogPerspectiveDefault

- (CircleCollection *)circleCollectionForPage:(NSUInteger)page
{
  NSArray *circles = [self.database circlesInPage:page];
  return [[CircleCollection alloc] initWithCircles:circles maxCount:self.numberOfCirclesPerCollection respectsCutIndex:YES];
}

#pragma mark Concrete Methods

- (NSUInteger)numberOfCircleCollections
{
  return self.database.pageSet.count;
}

- (CircleCollection *)circleCollectionAtIndex:(NSUInteger)index
{
  NSAssert(index < self.numberOfCircleCollections, @"index must be less than the number of circle collections");
  return [self circleCollectionForPage:[self pageAtIndex:index]];
}

@end

#pragma mark -
#pragma mark CatalogPerspectiveFiltered (Concrete Subclass)

@interface CatalogPerspectiveFiltered : CatalogPerspective

@end

@implementation CatalogPerspectiveFiltered

- (NSArray *)circlesWithLimit:(NSUInteger)limit offset:(NSUInteger)offset
{
  NSString *sqlFormat = @"SELECT * FROM %@ LIMIT %lu OFFSET %lu;";
  NSString *sql = [NSString stringWithFormat:sqlFormat, self.viewName, (unsigned long)limit, (unsigned long)offset];
  FMResultSet *result = [self.fmDatabase executeQuery:sql, self.viewName];
  NSMutableArray *circles = [NSMutableArray array];
  while ([result next]) {
    [circles addObject:[Circle circleWithResultSet:result]];
  }
  return [circles copy];
}

#pragma mark Concrete Methods

- (NSUInteger)numberOfCircleCollections
{
   BOOL hasRemainder = self.numberOfCircles % self.numberOfCirclesPerCollection != 0;
   return self.numberOfCircles / self.numberOfCirclesPerCollection + (hasRemainder ? 1 : 0);
}

- (CircleCollection *)circleCollectionAtIndex:(NSUInteger)index
{
  NSAssert(index < self.numberOfCircleCollections, @"index must be less than the number of circle collections");
  NSUInteger limit = self.numberOfCirclesPerCollection;
  NSUInteger offset = index * self.numberOfCirclesPerCollection;
  NSArray *circles = [self circlesWithLimit:limit offset:offset];
  return [[CircleCollection alloc] initWithCircles:circles maxCount:self.numberOfCirclesPerCollection respectsCutIndex:NO];
}

@end

#pragma mark -
#pragma mark CatalogPerspective (Abstract Superclass)

@implementation CatalogPerspective

@synthesize count = _count;

+ (CatalogPerspective *)perspectiveWithDatabase:(CatalogDatabase *)database
{
  return [self perspectiveWithDatabase:database filter:nil];
}

+ (CatalogPerspective *)perspectiveWithDatabase:(CatalogDatabase *)database filter:(CatalogFilter *)filter
{
  filter = filter ?: [CatalogFilter passthroughFilter];
  Class class = ([filter isEqual:[CatalogFilter passthroughFilter]]
                 ? [CatalogPerspectiveDefault class]
                 : [CatalogPerspectiveFiltered class]);
  return [[class alloc] initWithDatabase:database filter:filter];
}


- (instancetype)initWithDatabase:(CatalogDatabase *)database filter:(CatalogFilter *)filter
{
  self = [super init];
  if (!self) return nil;

  self.database = database;
  self.fmDatabase = database.database;
  self.filter = filter;
  _count = NSNotFound;

  [self createView];

  return self;
}

- (void)dealloc
{
  [self dropView];
}

- (NSUInteger)count
{
  if (_count == NSNotFound) {
    NSString *sqlFormat = @"SELECT COUNT(*) FROM %@ WHERE pageNo > 0;";
    NSString *sql = [NSString stringWithFormat:sqlFormat, self.viewName];
    _count = [self.fmDatabase intForQuery:sql, self.viewName];
  }
  return _count;
}

- (NSUInteger)numberOfCircles
{
  return self.count;
}

- (NSUInteger)numberOfCirclesPerCollection
{
  return self.database.numberOfCutsInRow * self.database.numberOfCutsInColumn;
}

- (NSUInteger)pageAtIndex:(NSUInteger)index
{
  __block NSUInteger page = 0;
  __block NSUInteger i = index;

  [self.database.pageSet enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
    if (i > range.length) {
      i -= range.length + 1;
    }
    else {
      page = range.location + i;
      *stop = YES;
    }
  }];

  return page;
}

- (NSUInteger)numberOfCircleCollections
{
  ABSTRACT_METHOD;
  return 0;
}

- (CircleCollection *)circleCollectionAtIndex:(NSUInteger)index
{
  ABSTRACT_METHOD;
  return nil;
}

#pragma mark View Management

- (void)createView
{
  NSString *sqlFormat = @"CREATE TEMPORARY VIEW %@ AS %@;";
  NSString *sql = [NSString stringWithFormat:
                   sqlFormat,
                   self.viewName,
                   self.filter.selectStatement];
  NSAssert([self.fmDatabase executeUpdate:sql], @"CREATE VIEW must succeed: %@", self.fmDatabase.lastError);
}

- (void)dropView
{
  NSString *sqlFormat = @"DROP VIEW IF EXISTS %@;";
  NSString *sql = [NSString stringWithFormat:sqlFormat, self.viewName];
  NSAssert(([self.fmDatabase executeUpdate:sql, self.viewName]), @"DROP VIEW must succeed: %@", self.fmDatabase.lastError);
}

- (NSString *)viewName
{
  return [NSString stringWithFormat:@"%@_%tx",
          NSStringFromClass([self class]),
          (void *)self];
}
@end
