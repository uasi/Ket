#import "CatalogPerspective.h"

#import "Circle.h"
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseAdditions.h>

@interface CatalogPerspective ()

@property (nonatomic) FMDatabase *database;

@property (nonatomic, readonly) NSString *viewName;

@end

@implementation CatalogPerspective

@synthesize count = _count;

- (instancetype)initWithDatabase:(FMDatabase *)database
{
  self = [super init];
  if (!self) return nil;

  self.database = database;
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

- (void)createView
{
  static NSString *query = (@"CREATE TEMPORARY VIEW (?)"
                            @"AS SELECT * FROM ComiketCircle;");
  [self.database executeQuery:query, self.viewName];
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
