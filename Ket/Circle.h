#import <Foundation/Foundation.h>

@class FMResultSet;

typedef NS_ENUM(NSUInteger, CircleSpaceSub) {
  CircleSpaceSubA = 0,
  CircleSpaceSubB = 1,
};

@interface Circle : NSObject

@property (readonly, assign, nonatomic) NSUInteger identifier;
@property (readonly, assign, nonatomic) NSUInteger page;
@property (readonly, assign, nonatomic) NSUInteger cutIndex; // in [1, 36].
@property (readonly, assign, nonatomic) NSUInteger space;
@property (readonly, assign, nonatomic) CircleSpaceSub spaceSub;
@property (readonly, nonatomic) NSString *spaceString;

+ (instancetype)circleWithResultSet:(FMResultSet *)result;

@end
