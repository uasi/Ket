#import <Foundation/Foundation.h>

@class FMResultSet;

typedef NS_ENUM(NSUInteger, CircleSpaceSub) {
  CircleSpaceSubA = 0,
  CircleSpaceSubB = 1,
};

@interface Circle : NSObject
                                                         // Column Name
@property (nonatomic, readonly) NSUInteger comiketNo;    // comiketNo
@property (nonatomic, readonly) NSUInteger identifier;   // id
@property (nonatomic, readonly) NSUInteger globalID;     // (N/A)
@property (nonatomic, readonly) NSUInteger page;         // pageNo
@property (nonatomic, readonly) NSUInteger cutIndex;     // cutIndex (in [1, 36])
@property (nonatomic, readonly) NSUInteger day;          // day
@property (nonatomic, readonly) NSUInteger blockID;      // blockId
@property (nonatomic, readonly) NSUInteger space;        // spaceNo
@property (nonatomic, readonly) CircleSpaceSub spaceSub; // spaceNoSub
@property (nonatomic, readonly) NSString *spaceString;   // (N/A)
@property (nonatomic, readonly) NSUInteger genreID;      // genreId
@property (nonatomic, readonly) NSString *circleName;    // circleName
@property (nonatomic, readonly) NSString *circleKana;    // circleKana
@property (nonatomic, readonly) NSString *author;        // penName
@property (nonatomic, readonly) NSString *title;         // bookName
@property (nonatomic, readonly) NSURL *URL;              // URL
@property (nonatomic, readonly) NSString *mailAddress;   // mailAddr
@property (nonatomic, readonly) NSString *note;          // description
@property (nonatomic, readonly) NSString *memo;          // memo
@property (nonatomic, readonly) NSUInteger updateID;     // updateId
@property (nonatomic, readonly) NSString *updateInfo;    // updateData
@property (nonatomic, readonly) NSURL *circlemsURL;      // circlems
@property (nonatomic, readonly) NSURL *RSSURL;           // rss
@property (nonatomic, readonly) NSUInteger updateFlag;   // updateFlag

+ (Circle *)emptyCircle;
+ (instancetype)circleWithResultSet:(FMResultSet *)result;

- (NSComparisonResult)compare:(Circle *)circle;

- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

@end
