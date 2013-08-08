#import "Checklist.h"

#import "Circle.h"

NSString *const ChecklistDidChangeNotification = @"ChecklistDidChangeNotification";

@interface Checklist ()

@property (nonatomic, readwrite) NSUInteger comiketNo;

@property (nonatomic) NSMutableDictionary *entries;

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
  self.entries = [[NSMutableDictionary alloc] init];

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
  self.entries = [(properties[@"dictionaryOfProperties"] ?: @{}) mutableCopy];

  return self;
}

- (id)copyWithZone:(NSZone *)zone __unused
{
  Checklist *newChecklist = [[Checklist alloc] init];
  newChecklist.comiketNo = self.comiketNo;
  newChecklist.entries = [self.entries mutableCopy];
  return newChecklist;
}

#pragma mark Writing

#define BEGIN_WRITING \
NSAssert(!self.frozen, @"must not to mutate a snapshot"); \
[self invalidateCachedState];

#define END_WRITING \
[self postNotification];

- (void)addCircleToBookmarks:(Circle *)circle
{
  NSAssert(circle, @"circle must not be nil");
  BEGIN_WRITING;
  [self entryForCircle:circle][@"colorCode"] = @(1);
  END_WRITING;
}

- (void)removeCircleFromBookmarks:(Circle *)circle
{
  NSAssert(circle, @"circle must not be nil");
  BEGIN_WRITING;
  [[self entryForCircle:circle] removeObjectForKey:@"colorCode"];
  END_WRITING;
}

- (void)setColorCode:(NSInteger)colorCode forCircle:(Circle *)circle
{
  NSAssert(circle, @"circle must not be nil");
  [self setColorCode:colorCode forCircleWithGlobalID:circle.globalID];
}

- (void)setColorCode:(NSInteger)colorCode forCircleWithGlobalID:(NSUInteger)globalID
{
  NSAssert(globalID, @"globalID must not be zero");
  NSAssert(0 <= colorCode && colorCode <= 9, @"colorCode must be between 0 and 9");
  BEGIN_WRITING;
  if (colorCode == 0) {
    [[self entryForGlobalID:globalID] removeObjectForKey:@"colorCode"];
  }
  else {
    [self entryForGlobalID:globalID][@"colorCode"] = @(colorCode);
  }
  END_WRITING;
}

#pragma mark Reading

- (BOOL)bookmarksContainsCircle:(Circle *)circle
{
  if (!circle) return NO;
  return !!self.entries[(@(circle.globalID))][@"colorCode"];
}

- (BOOL)bookmarksContainsCircleWithGlobalID:(NSUInteger)globalID
{
  return !!self.entries[@(globalID)][@"colorCode"];
}

- (NSColor *)colorForCircle:(Circle *)circle
{
  return [self colorForCode:[self colorCodeForCircle:circle]];
}

- (NSInteger)colorCodeForCircle:(Circle *)circle
{
  NSNumber *codeNumber = self.entries[@(circle.globalID)][@"colorCode"] ?: @0;
  return [codeNumber integerValue];
}

#define BGR(b, g, r) \
[NSColor colorWithCalibratedRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]

- (NSColor *)colorForCode:(NSInteger)colorCode
{
  // The default color palette of Comiket Catalog Browser for Windows.
  switch (colorCode) {
    case 1: return BGR(74, 148, 255);
    case 2: return BGR(255, 0, 255);
    case 3: return BGR(0, 247, 255);
    case 4: return BGR(74, 181, 0);
    case 5: return BGR(255, 181, 0);
    case 6: return BGR(156, 82, 156);
    case 7: return BGR(255, 0, 0);
    case 8: return BGR(0, 255, 0);
    case 9: return BGR(0, 0, 255);
    default: return [NSColor clearColor];
  }
}

- (NSIndexSet *)globalIDSet
{
  if (_globalIDSet) return _globalIDSet;
  [self removeEmptyEntries];
  NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
  for (NSNumber *globalID in self.entries) {
    [set addIndex:globalID.unsignedIntegerValue];
  }
  _globalIDSet = [set copy];
  return _globalIDSet;
}

- (NSData *)data
{
  if (_data) return _data;
  [self removeEmptyEntries];
  _data = [NSKeyedArchiver archivedDataWithRootObject:@{
           @"entries": self.entries,
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

#pragma mark Entry Management

- (NSMutableDictionary *)entryForCircle:(Circle *)circle
{
  return [self entryForGlobalID:circle.globalID];
}

- (NSMutableDictionary *)entryForGlobalID:(NSUInteger)globalID
{
  NSMutableDictionary *properties = self.entries[@(globalID)];
  if (properties) return properties;

  properties = [NSMutableDictionary dictionary];
  self.entries[@(globalID)] = properties;
  return properties;
}

// Method that returns aggregated information about entries should call this
// method first.
- (void)removeEmptyEntries
{
  for (id key in self.entries.allKeys) {
    if (((NSMutableDictionary *)self.entries[key]).count == 0) {
      [self.entries removeObjectForKey:key];
    }
  }
}

#pragma mark Notification

- (void)postNotification
{
  void (^post)(void) = ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:ChecklistDidChangeNotification object:self];
  };
  if ([NSThread isMainThread]) post();
  else dispatch_async(dispatch_get_main_queue(), post);
}

#pragma mark Cached State Management

- (void)invalidateCachedState
{
  _globalIDSet = nil;
  _data = nil;
  _snapshot = nil;
}

@end
