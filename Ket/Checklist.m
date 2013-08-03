#import "Checklist.h"

#import "Circle.h"

@interface Checklist ()

@property (nonatomic) NSMutableDictionary *bookmarks;

@end

@implementation Checklist

- (instancetype)initWithComiketNo:(NSUInteger)comiketNo
{
  self = [super init];
  if (!self) return nil;

  self.bookmarks = [[NSMutableDictionary alloc] init];

  return self;
}

- (instancetype)initWithData:(NSData *)data error:(NSError **)error
{
  self = [super init];
  if (!self) return nil;

  NSDictionary *properties = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  if (!properties && error) {
    *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:nil];
    return nil;
  }

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
   }];
}

@end
