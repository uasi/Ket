#import "Checklist.h"

#import "Circle.h"

@interface Checklist ()

@property (nonatomic, readwrite) NSUInteger comiketNo;

@property (nonatomic) NSMutableDictionary *bookmarks;

// Snapshot management
@property (nonatomic) BOOL frozen;
@property (nonatomic) Checklist *snapshot;

@end

@implementation Checklist

@synthesize globalIDSet = _globalIDSet;
@synthesize data = _data;
@synthesize snapshot = _snapshot;

#pragma mark Initializing And Copying

- (instancetype)initWithComiketNo:(NSUInteger)comiketNo
{
  if (self) NSAssert(!self.frozen, @"must not to re-initialize a snapshot");

  self = [super init];
  if (!self) return nil;

  self.comiketNo = comiketNo;
  self.bookmarks = [[NSMutableDictionary alloc] init];

  return self;
}

- (instancetype)initWithData:(NSData *)data error:(NSError **)error
{
  if (self) NSAssert(!self.frozen, @"must not to re-initialize a snapshot");

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

- (id)copyWithZone:(NSZone *)zone __unused
{
  Checklist *newChecklist = [[Checklist alloc] init];
  newChecklist.comiketNo = self.comiketNo;
  newChecklist.bookmarks = [self.bookmarks mutableCopy];
  return newChecklist;
}

#pragma mark Writing

#define WRITING \
NSAssert(!self.frozen, @"must not to mutate a snapshot"); \
[self invalidateCachedState];

- (void)addCircleToBookmarks:(Circle *)circle
{
  NSAssert(circle, @"circle must not be nil");
  WRITING;
  self.bookmarks[@(circle.globalID)] = @YES;
}

- (void)removeCircleFromBookmarks:(Circle *)circle
{
  NSAssert(circle, @"circle must not be nil");
  WRITING;
  [self.bookmarks removeObjectForKey:@(circle.globalID)];
}

#pragma mark Reading

- (BOOL)bookmarksContainsCircle:(Circle *)circle
{
  if (!circle) return NO;
  return !!self.bookmarks[@(circle.globalID)];
}

- (BOOL)bookmarksContainsCircleWithGlobalID:(NSUInteger)globalID
{
  return !!self.bookmarks[@(globalID)];
}

- (NSIndexSet *)globalIDSet
{
  if (_globalIDSet) return _globalIDSet;
  NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
  for (NSNumber *globalID in self.bookmarks) {
    [set addIndex:globalID.unsignedIntegerValue];
  }
  _globalIDSet = [set copy];
  return _globalIDSet;
}

- (NSData *)data
{
  if (_data) return _data;
  _data = [NSKeyedArchiver archivedDataWithRootObject:@{
           @"bookmarks": self.bookmarks,
           @"comiketNo": @(self.comiketNo),
           }];
  return _data;
}

- (id<ChecklistReading>)snapshot
{
  if (_snapshot) return _snapshot;
  _snapshot = [self copy];
  _snapshot.frozen = YES;
  return _snapshot;
}

- (NSString *)identifier
{
  return [NSString stringWithFormat:
          @"%@_%tx",
          NSStringFromClass([self class]),
          (void *)self];
}

#pragma mark Cached State Management

- (void)invalidateCachedState
{
  _globalIDSet = nil;
  _data = nil;
  _snapshot = nil;
}

@end
