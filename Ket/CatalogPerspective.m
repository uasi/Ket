#import "CatalogPerspective.h"

#import "CatalogDatabase.h"
#import "CatalogFilter.h"
#import "Circle.h"
#import "CircleCollection.h"
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseAdditions.h>

@interface CatalogDatabase (CatalogPerspective_Private)

@property (nonatomic, readonly) FMDatabase *database;

@end

@interface CatalogPerspective ()

@property (nonatomic) CatalogDatabase *database;
@property (nonatomic, weak) FMDatabase *fmDatabase;

@property (nonatomic, readonly) NSUInteger numberOfCirclesInCollection;
@property (nonatomic, readonly) NSString *viewName;

// XXX: for CirclePerspectiveFiletered
- (instancetype)initWithDatabase:(CatalogDatabase *)database;
- (void)dropView;

@end

#pragma mark -
#pragma mark CatalogPerspectiveDefault (Concrete Subclass)

@interface CatalogPerspectiveDefault : CatalogPerspective

@end

@implementation CatalogPerspectiveDefault

- (CircleCollection *)circleCollectionForPage:(NSUInteger)page
{
  NSArray *circles = [self.database circlesInPage:page];
  return [[CircleCollection alloc] initWithCircles:circles count:self.numberOfCirclesInCollection respectsCutIndex:YES];
}

#pragma mark Concrete Methods

- (NSUInteger)numberOfCircleCollections
{
  return self.database.pageSet.count;
}

- (CircleCollection *)circleCollectionAtIndex:(NSUInteger)index
{
  NSAssert(index < self.numberOfCircleCollections, @"index must be less than the number of circle collections");
  NSUInteger page = [self pageAtIndex:index];
  return [self circleCollectionForPage:page];
}

@end

#pragma mark -
#pragma mark CatalogPerspectiveFiltered (Concrete Subclass)

@interface CatalogPerspectiveFiltered : CatalogPerspective

@end

@implementation CatalogPerspectiveFiltered

- (instancetype)initWithDatabase:(CatalogDatabase *)database
{
  self = [super initWithDatabase:database];

  // XXX: a simple and stupid filter
  [self dropView];
  static NSString *sqlFormat = (@"CREATE TEMPORARY VIEW %@"
                                @"  AS SELECT * FROM ComiketCircle WHERE pageNo < 100 AND pageNo != 0;");
  NSString *sql = [NSString stringWithFormat:sqlFormat, self.viewName];
  NSAssert([self.fmDatabase executeUpdate:sql], @"CREATE VIEW must succeed");

  return self;
}

- (NSArray *)circlesWithLimit:(NSUInteger)limit offset:(NSUInteger)offset
{
  static NSString *sqlFormat = @"SELECT * FROM %@ LIMIT %lu OFFSET %lu;";
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
   BOOL hasRemainder = self.numberOfCircles % self.numberOfCirclesInCollection != 0;
   return self.numberOfCircles / self.numberOfCirclesInCollection + (hasRemainder ? 1 : 0);
}

- (CircleCollection *)circleCollectionAtIndex:(NSUInteger)index
{
  NSAssert(index < self.numberOfCircleCollections, @"index must be less than the number of circle collections");
  NSUInteger limit = self.numberOfCirclesInCollection;
  NSUInteger offset = index * self.numberOfCirclesInCollection;
  NSArray *circles = [self circlesWithLimit:limit offset:offset];
  return [[CircleCollection alloc] initWithCircles:circles count:self.numberOfCirclesInCollection respectsCutIndex:NO];
}

@end

#pragma mark -
#pragma mark CatalogPerspective (Abstract Superclass)

@implementation CatalogPerspective

@synthesize count = _count;

+ (CatalogPerspective *)perspectiveWithDatabase:(CatalogDatabase *)database
{
  return [[CatalogPerspectiveDefault alloc] initWithDatabase:database];
}

+ (CatalogPerspective *)perspectiveWithDatabase:(CatalogDatabase *)database filter:(CatalogFilter *)filter
{
  filter; // XXX: use me!
  return [[CatalogPerspectiveFiltered alloc] initWithDatabase:database];
}


- (instancetype)initWithDatabase:(CatalogDatabase *)database
{
  self = [super init];
  if (!self) return nil;

  self.database = database;
  self.fmDatabase = database.database;
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
    static NSString *sqlFormat = @"SELECT COUNT(*) FROM %@ WHERE pageNo > 0;";
    NSString *sql = [NSString stringWithFormat:sqlFormat, self.viewName];
    _count = [self.fmDatabase intForQuery:sql, self.viewName];
  }
  return _count;
}

- (NSUInteger)numberOfCircles
{
  return self.count;
}

- (NSUInteger)numberOfCirclesInCollection
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

#pragma mark View Management

- (void)createView
{
  static NSString *sqlFormat = (@"CREATE TEMPORARY VIEW %@"
                                @"  AS SELECT * FROM ComiketCircle;");
  NSString *sql = [NSString stringWithFormat:sqlFormat, self.viewName];
  NSAssert([self.fmDatabase executeUpdate:sql], @"CREATE VIEW must succeed");
}

- (void)dropView
{
  static NSString *sqlFormat = @"DROP VIEW IF EXISTS %@;";
  NSString *sql = [NSString stringWithFormat:sqlFormat, self.viewName];
  NSAssert(([self.fmDatabase executeUpdate:sql, self.viewName]), @"DROP VIEW must succeed");
}

- (NSString *)viewName
{
  return [NSString stringWithFormat:@"view_%lx", (unsigned long)self.hash];
}

#pragma mark Abstract Methods

- (NSUInteger)numberOfCircleCollections
{
  NSAssert(NO, @"");
  return 0;
}

- (CircleCollection *)circleCollectionAtIndex:(NSUInteger)index
{
  NSAssert(NO, @"");
  return nil;
}

@end
