#import "Circle.h"

#import <FMDB/FMResultSet.h>

@interface Circle ()

@property (nonatomic, readwrite) NSUInteger comiketNo;
@property (nonatomic, readwrite) NSUInteger identifier;
@property (nonatomic, readwrite) NSUInteger page;
@property (nonatomic, readwrite) NSUInteger cutIndex;
@property (nonatomic, readwrite) NSUInteger space;
@property (nonatomic, readwrite) CircleSpaceSub spaceSub;
@property (nonatomic, readwrite) NSUInteger blockID;
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

@dynamic spaceString;

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
  self.space = [result intForColumn:@"spaceNo"];
  self.spaceSub = (CircleSpaceSub)[result intForColumn:@"spaceNoSub"];
  self.blockID = [result intForColumn:@"blockId"];
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
