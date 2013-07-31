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
    static NSString *sqlFormat = @"SELECT COUNT(*) FROM %@;";
    NSString *sql = [NSString stringWithFormat:sqlFormat, self.viewName];
    _count = [self.database intForQuery:sql, self.viewName];
  }
  return _count;
}

- (NSArray *)circlesWithLimit:(NSUInteger)limit offset:(NSUInteger)offset
{
  static NSString *sqlFormat = @"SELECT * FROM %@ LIMIT (?) OFFSET (?);";
  NSString *sql = [NSString stringWithFormat:sqlFormat, self.viewName];
  FMResultSet *result = [self.database executeQuery:sql, self.viewName, @(limit), @(offset)];
  NSMutableArray *circles = [NSMutableArray array];
  while ([result next]) {
    [circles addObject:[Circle circleWithResultSet:result]];
  }
  return [circles copy];
}

#pragma mark View Management

- (void)createView
{
  static NSString *sqlFormat = (@"CREATE TEMPORARY VIEW %@"
                                @"  AS SELECT * FROM ComiketCircle;");
  NSString *sql = [NSString stringWithFormat:sqlFormat, self.viewName];
  NSAssert([self.database executeUpdate:sql], @"CREATE VIEW must succeed");
}

- (void)dropView
{
  static NSString *sqlFormat = @"DROP VIEW IF EXISTS %@;";
  NSString *sql = [NSString stringWithFormat:sqlFormat, self.viewName];
  NSAssert(([self.database executeUpdate:sql, self.viewName]), @"DROP VIEW must succeed");
}

- (NSString *)viewName
{
  return [NSString stringWithFormat:@"view_%lx", (unsigned long)self.hash];
}

@end
