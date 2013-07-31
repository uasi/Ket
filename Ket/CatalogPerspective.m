#import "CatalogPerspective.h"

#import "CatalogDatabase.h"
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

@end

@implementation CatalogPerspective

@synthesize count = _count;

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

- (NSUInteger)numberOfCircleCollections
{
  return self.database.pageSet.count;
  // XXX: will be used by a filtered perspective
  /*
  BOOL hasRemainder = self.numberOfCircles % self.numberOfCirclesInCollection != 0;
  return self.numberOfCircles / self.numberOfCirclesInCollection + (hasRemainder ? 1 : 0);
   */
}

// XXX: should be configurable (by the data provider?)
- (NSUInteger)numberOfCirclesInCollection
{
  return self.database.numberOfCutsInRow * self.database.numberOfCutsInColumn;
}

// XXX: will be used by a filtered perspective
/*
- (NSArray *)circlesWithLimit:(NSUInteger)limit offset:(NSUInteger)offset
{
  static NSString *sqlFormat = @"SELECT * FROM %@ LIMIT (?) OFFSET (?);";
  NSString *sql = [NSString stringWithFormat:sqlFormat, self.viewName];
  FMResultSet *result = [self.fmDatabase executeQuery:sql, self.viewName, @(limit), @(offset)];
  NSMutableArray *circles = [NSMutableArray array];
  while ([result next]) {
    [circles addObject:[Circle circleWithResultSet:result]];
  }
  return [circles copy];
}
 */

- (CircleCollection *)circleCollectionAtIndex:(NSUInteger)index
{
  NSAssert(index < self.numberOfCircleCollections, @"index must be less than the number of circle collections");
  NSUInteger page = [self pageAtIndex:index];
  return [self.database circleCollectionForPage:page];
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

@end
