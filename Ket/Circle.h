#import <Foundation/Foundation.h>

@class FMResultSet;

typedef NS_ENUM(NSUInteger, CircleSpaceSub) {
  CircleSpaceSubA = 0,
  CircleSpaceSubB = 1,
};

@interface Circle : NSObject

@property (nonatomic, readonly) NSUInteger identifier;
@property (nonatomic, readonly) NSUInteger page;
@property (nonatomic, readonly) NSUInteger cutIndex; // in [1, 36].
@property (nonatomic, readonly) NSUInteger space;
@property (nonatomic, readonly) CircleSpaceSub spaceSub;
@property (nonatomic, readonly) NSUInteger blockID;
@property (nonatomic, readonly) NSString *spaceString;

+ (instancetype)circleWithResultSet:(FMResultSet *)result;

@end
