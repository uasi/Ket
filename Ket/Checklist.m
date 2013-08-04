#import "Checklist.h"

#import "Circle.h"

@interface Checklist ()

@property (nonatomic) NSUInteger comiketNo;
@property (nonatomic) NSMutableDictionary *bookmarks;

@end

@implementation Checklist

- (instancetype)initWithComiketNo:(NSUInteger)comiketNo
{
  self = [super init];
  if (!self) return nil;

  self.comiketNo = comiketNo;
  self.bookmarks = [[NSMutableDictionary alloc] init];

  return self;
}

- (instancetype)initWithData:(NSData *)data error:(NSError **)error
{
  self = [super init];
  if (!self) return nil;

  NSDictionary *properties = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  if (!properties) {
    if (error) {
      NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey:@"could not unarchive data"};
      *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:userInfo];
    }
    return nil;
  }

  NSNumber *comiketNo = properties[@"comiketNo"];
  if (!comiketNo) {
    if (error) {
      NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: @"comiketNo is not set"};
      *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:userInfo];
    }
    return nil;
  }
  self.comiketNo = [comiketNo unsignedIntegerValue];
  self.bookmarks = [(properties[@"bookmarks"] ?: @[]) mutableCopy];

  return self;
}

- (void)addCircleToBookmarks:(Circle *)circle
{
  NSAssert(circle, @"circle must not be nil");
  self.bookmarks[@(circle.globalID)] = @YES;
}

- (void)removeCircleFromBookmarks:(Circle *)circle
{
  NSAssert(circle, @"circle must not be nil");
  [self.bookmarks removeObjectForKey:@(circle.globalID)];
}

- (BOOL)bookmarksContainsCircle:(Circle *)circle
{
  if (!circle) return NO;
  return !!self.bookmarks[@(circle.globalID)];
}

- (NSData *)data
{
  return [NSKeyedArchiver archivedDataWithRootObject:@{
          @"bookmarks": self.bookmarks,
          @"comiketNo": @(self.comiketNo),
          }];
}

@end
