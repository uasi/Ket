#import "Circle.h"
#import <FMDB/FMResultSet.h>

@interface Circle ()

@property (readwrite, assign, nonatomic) NSUInteger identifier;
@property (readwrite, assign, nonatomic) NSUInteger page;
@property (readwrite, assign, nonatomic) NSUInteger cutIndex;
@property (readwrite, assign, nonatomic) NSUInteger space;
@property (readwrite, assign, nonatomic) NSUInteger blockID;
@property (readwrite, assign, nonatomic) CircleSpaceSub spaceSub;

@end

@implementation Circle

@dynamic spaceString;

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
  self.space = [result intForColumn:@"spaceNo"];
  self.spaceSub = (CircleSpaceSub)[result intForColumn:@"spaceNoSub"];
  self.blockID = [result intForColumn:@"blockId"];
  
  return self;
}

- (instancetype)init
{
  @throw NSInternalInconsistencyException;
}

- (NSString *)spaceString
{
  NSString *sub = (self.spaceSub == CircleSpaceSubA) ? @"a" : @"b";
  return [NSString stringWithFormat:@"%d%@", (int)self.space, sub];
}

@end
