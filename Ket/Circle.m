#import "Circle.h"

#import <FMDB/FMResultSet.h>

@interface Circle ()

@property (nonatomic, readwrite) NSUInteger identifier;
@property (nonatomic, readwrite) NSUInteger page;
@property (nonatomic, readwrite) NSUInteger cutIndex;
@property (nonatomic, readwrite) NSUInteger space;
@property (nonatomic, readwrite) NSUInteger blockID;
@property (nonatomic, readwrite) CircleSpaceSub spaceSub;

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
