#import "CatalogDatabase.h"
#import "Circle.h"
#import <sqlite3.h>
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseAdditions.h>
#import <FMDB/FMResultSet.h>

#define CIRCLE_COUNT_PER_PAGE 36

@interface CatalogDatabase ()

@property (strong, nonatomic) FMDatabase *database;

@end

@implementation CatalogDatabase

@dynamic comiketNo;
@dynamic cutSize;
@dynamic cutOrigin;
@synthesize pageNoIndexSet = _pageNoIndexSet;

+ (CatalogDatabase *)databaseWithContentsOfFile:(NSString *)file
{
  return [[[self class] alloc] initWithContentsOfFile:file];
}

- (instancetype)initWithContentsOfFile:(NSString *)file
{
  self = [super init];
  if (!self) return nil;

  self.database = [FMDatabase databaseWithPath:file];
  if (![self.database openWithFlags:SQLITE_OPEN_READONLY]) return nil;

  return self;
}

- (instancetype)init
{
  @throw NSInternalInconsistencyException;
}

- (void)dealloc
{
  [self.database close];
}

- (NSInteger)comiketNo
{
  return [self.database intForQuery:@"SELECT comiketNo FROM ComiketInfo;"];
}

- (NSSize)cutSize
{
  CGFloat w = [self.database intForQuery:@"SELECT cutSizeW FROM ComiketInfo;"];
  CGFloat h = [self.database intForQuery:@"SELECT cutSizeH FROM ComiketInfo;"];
  return NSMakeSize(w, h);
}

- (NSPoint)cutOrigin
{
  CGFloat x = [self.database intForQuery:@"SELECT cutOriginX FROM ComiketInfo"];
  CGFloat y = [self.database intForQuery:@"SELECT cutOriginY FROM ComiketInfo"];
  return NSMakePoint(x, y);
}

- (NSIndexSet *)pageNoIndexSet
{
  if (_pageNoIndexSet) return _pageNoIndexSet;

  NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];

  NSString *query = (@"SELECT DISTINCT pageNo FROM ComiketCircle"
                     @"  WHERE pageNo > 0"
                     @"  ORDER BY pageNo ASC;");
  FMResultSet *result = [self.database executeQuery:query];
  while ([result next]) {
    [indexSet addIndex:[result intForColumnIndex:0]];
  }

  return _pageNoIndexSet = [indexSet copy];
}

- (NSArray *)circlesInPage:(NSUInteger)page
{
  NSMutableArray *circles = [NSMutableArray arrayWithCapacity:CIRCLE_COUNT_PER_PAGE];

  NSString *query = (@"SELECT * FROM ComiketCircle"
                     @"  WHERE pageNo = (?)"
                     @"  ORDER BY cutIndex ASC;");
  FMResultSet *result = [self.database executeQuery:query, [NSNumber numberWithUnsignedInteger:page]];
  while ([result next]) {
    [circles addObject:[Circle circleWithResultSet:result]];
  }

  return [circles copy];
}

- (NSArray *)circlesInPagePaddedWithNull:(NSUInteger)page
{
  NSMutableArray *paddedCircles = [NSMutableArray arrayWithCapacity:CIRCLE_COUNT_PER_PAGE];
  NSArray *circles = [self circlesInPage:page];

  NSInteger circleIndex = 0;
  for (NSInteger cutIndex = 1; cutIndex <= CIRCLE_COUNT_PER_PAGE; cutIndex++) {
    if (circleIndex >= circles.count || cutIndex != ((Circle *)circles[circleIndex]).cutIndex) {
      paddedCircles[cutIndex - 1] = [NSNull null];
    }
    else {
      paddedCircles[cutIndex - 1] = circles[circleIndex++];
    }
  }

  return paddedCircles;
}

@end
