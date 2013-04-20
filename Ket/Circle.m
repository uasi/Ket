#import "Circle.h"
#import <FMDB/FMResultSet.h>

@interface Circle ()

@property (readwrite, assign, nonatomic) NSUInteger identifier;
@property (readwrite, assign, nonatomic) NSUInteger page;
@property (readwrite, assign, nonatomic) NSUInteger cutIndex;

@end

@implementation Circle

+ (instancetype)circleWithResultSet:(FMResultSet *)result
{
  return [[[self class] alloc] initWithResultSet:(FMResultSet *)result];
}

- (instancetype)initWithResultSet:(FMResultSet *)result
{
  self = [super init];
  if (!self) return nil;

  self.identifier = [result intForColumn:@"id"];
  self.page = [result intForColumn:@"pageNo"];
  self.cutIndex = [result intForColumn:@"cutIndex"];
  
  return self;
}

- (instancetype)init
{
  @throw NSInternalInconsistencyException;
}

@end
