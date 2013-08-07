#import "Circle.h"

#import "PathUtils.h"
#import <FMDB/FMResultSet.h>

NSUInteger GlobalCircleIDMake(NSUInteger comiketNo, NSUInteger circleID)
{
  return (comiketNo << 24) | circleID;
}

NSUInteger ComiketNoFromGlobalCircleID(NSUInteger globalID)
{
  return globalID >> 24;
}

NSUInteger CircleIdentifierFromGlobalCircleID(NSUInteger globalID)
{
  return globalID & 0x00FFFFFF;
}

#pragma mark - EmptyCircle

@interface EmptyCircle : Circle
@end

@implementation EmptyCircle

#pragma mark NSObject Protocol

- (NSUInteger)hash
{
  return 0;
}

- (NSString *)description
{
  return @"<(empty circle)>";
}

@end

#pragma mark - Circle

@interface Circle ()

@property (nonatomic, readwrite) NSUInteger comiketNo;
@property (nonatomic, readwrite) NSUInteger identifier;
@property (nonatomic, readwrite) NSUInteger page;
@property (nonatomic, readwrite) NSUInteger cutIndex;
@property (nonatomic, readwrite) NSUInteger day;
@property (nonatomic, readwrite) NSUInteger blockID;
@property (nonatomic, readwrite) NSUInteger space;
@property (nonatomic, readwrite) CircleSpaceSub spaceSub;
@property (nonatomic, readwrite) NSString *spaceString;
@property (nonatomic, readwrite) NSUInteger genreID;
@property (nonatomic, readwrite) NSString *circleName;
@property (nonatomic, readwrite) NSString *circleKana;
@property (nonatomic, readwrite) NSString *author;
@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) NSURL *URL;
@property (nonatomic, readwrite) NSString *mailAddress;
@property (nonatomic, readwrite) NSString *note;
@property (nonatomic, readwrite) NSString *memo;
@property (nonatomic, readwrite) NSUInteger updateID;
@property (nonatomic, readwrite) NSString *updateInfo;
@property (nonatomic, readwrite) NSURL *circlemsURL;
@property (nonatomic, readwrite) NSURL *RSSURL;
@property (nonatomic, readwrite) NSUInteger updateFlag;

@end

@implementation Circle

+ (Circle *)emptyCircle
{
  static EmptyCircle *emptyCircle;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    emptyCircle = [[EmptyCircle alloc] init];
  });
  return emptyCircle;
}

+ (instancetype)circleWithResultSet:(FMResultSet *)result
{
  return [[[self class] alloc] initWithResultSet:(FMResultSet *)result];
}

static NSURL *URLFromString(NSString *string) {
  NSURL *URL = [NSURL URLWithString:string];
  if (!URL) {
    DDLogCWarn(@"Could not parse URL string \"%@\"", string);
  }
  return URL;
}

- (instancetype)initWithResultSet:(FMResultSet *)result
{
  self = [super init];
  if (!self) return nil;

  self.comiketNo = [result intForColumn:@"comiketNo"];
  self.identifier = [result intForColumn:@"id"];
  self.page = [result intForColumn:@"pageNo"];
  self.cutIndex = [result intForColumn:@"cutIndex"];
  self.day = [result intForColumn:@"day"];
  self.blockID = [result intForColumn:@"blockId"];
  self.space = [result intForColumn:@"spaceNo"];
  self.spaceSub = (CircleSpaceSub)[result intForColumn:@"spaceNoSub"];
  self.genreID = [result intForColumn:@"genreId"];
  self.circleName = [result stringForColumn:@"circleName"];
  self.circleKana = [result stringForColumn:@"circleKana"];
  self.author = [result stringForColumn:@"penName"];
  self.title = [result stringForColumn:@"bookName"];
  self.URL = URLFromString([result stringForColumn:@"URL"]);
  self.mailAddress = [result stringForColumn:@"mailAddr"];
  self.note = [result stringForColumn:@"description"];
  self.memo = [result stringForColumn:@"memo"];
  self.updateID = [result intForColumn:@"updateId"];
  self.updateInfo = [result stringForColumn:@"updateData"];
  self.circlemsURL = URLFromString([result stringForColumn:@"rss"]);
  self.updateFlag = [result intForColumn:@"updateFlag"];
  
  return self;
}

- (NSString *)spaceString
{
  NSString *sub = (self.spaceSub == CircleSpaceSubA) ? @"a" : @"b";
  return [NSString stringWithFormat:@"%d%@", (int)self.space, sub];
}

- (NSComparisonResult)compare:(Circle *)circle
{
  if (self.comiketNo < circle.comiketNo) return NSOrderedAscending;
  if (self.comiketNo > circle.comiketNo) return NSOrderedDescending;
  if (self.identifier < circle.identifier) return NSOrderedAscending;
  if (self.identifier > circle.identifier) return NSOrderedDescending;
  return NSOrderedSame;
}

#pragma mark Accessors

- (NSUInteger)globalID
{
  return GlobalCircleIDMake(self.comiketNo, self.identifier);
}

#pragma mark NSObject Protocol

- (BOOL)isEqual:(id)object
{
  if (!object) return NO;
  if ([self class] != [object class]) return NO;
  return self.globalID == ((Circle *)object).globalID;
}

- (NSUInteger)hash
{
  return self.globalID;
}

- (NSString *)description
{
  if (self.page > 0) {
    return [NSString stringWithFormat:
            @"<%@ #%lu p%lu[%lu] %@>",
            ComiketNameFromComiketNo(self.comiketNo),
            (unsigned long)self.identifier,
            (unsigned long)self.page,
            (unsigned long)self.cutIndex,
            self.circleName];
  }
  else {
    return [NSString stringWithFormat:
            @"<%@ #%lu (unaccepted) %@>",
            ComiketNameFromComiketNo(self.comiketNo),
            (unsigned long)self.identifier,
            self.circleName];
  }
}

@end
