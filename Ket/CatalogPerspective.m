#import "CatalogPerspective.h"

#import "Circle.h"
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseAdditions.h>

@interface CatalogPerspective ()

@property (nonatomic) FMDatabase *database;
@property (nonatomic) NSString *filter;

@property (nonatomic, readonly) NSString *viewName;

@end

@implementation CatalogPerspective

@synthesize count = _count;

- (instancetype)initWithDatabase:(FMDatabase *)database filter:(NSString *)filter
{
  self = [super init];
  if (!self) return nil;

  self.database = database;
  self.filter = filter;
  _count = NSNotFound;

  [self createViewWithFilter:filter];

  return self;
}

- (void)dealloc
{
  [self dropView];
}

- (NSUInteger)count
{
  if (_count == NSNotFound) {
    static NSString *query = @"SELECT COUNT(*) FROM (?);";
    _count = [self.database intForQuery:query, self.viewName];
  }
  return _count;
}

- (NSArray *)circlesWithLimit:(NSUInteger)limit offset:(NSUInteger)offset
{
  static NSString *query = @"SELECT * FROM (?) LIMIT (?) OFFSET (?);";
  FMResultSet *result = [self.database executeQuery:query, self.viewName, @(limit), @(offset)];
  NSMutableArray *circles = [NSMutableArray array];
  while ([result next]) {
    [circles addObject:[Circle circleWithResultSet:result]];
  }
  return [circles copy];
}

#pragma mark View Management

- (void)createViewWithFilter:(NSString *)filter
{
  static NSString *query = (@"CREATE TEMPORARY VIEW (?1)"
                            @"AS SELECT * FROM ComiketCircle"
                            @"WHERE"
                            @"  circleName LIKE (?2) OR"
                            @"  circleKana LIKE (?2)"
                            @"ORDER BY cutIndex ASC;");
  [self.database executeQuery:query, self.viewName, filter];
}

- (void)dropView
{
  static NSString *query = @"DROP VIEW IF EXISTS (?);";
  [self.database executeQuery:query, self.viewName];
}

- (NSString *)viewName
{
  return [NSString stringWithFormat:@"view_%lx", (unsigned long)self.hash];
}

@end
