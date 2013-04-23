#import <Foundation/Foundation.h>

@class FMResultSet;

typedef NS_ENUM(NSUInteger, CircleSpaceSub) {
  CircleSpaceSubA = 0,
  CircleSpaceSubB = 1,
};

@interface Circle : NSObject

@property (nonatomic, readonly, assign) NSUInteger identifier;
@property (nonatomic, readonly, assign) NSUInteger page;
@property (nonatomic, readonly, assign) NSUInteger cutIndex; // in [1, 36].
@property (nonatomic, readonly, assign) NSUInteger space;
@property (nonatomic, readonly, assign) CircleSpaceSub spaceSub;
@property (nonatomic, readonly, assign) NSUInteger blockID;
@property (nonatomic, readonly) NSString *spaceString;

+ (instancetype)circleWithResultSet:(FMResultSet *)result;

@end
