#import <Foundation/Foundation.h>

@class FMResultSet;

@interface Circle : NSObject

@property (readonly, assign, nonatomic) NSUInteger identifier;
@property (readonly, assign, nonatomic) NSUInteger page;
@property (readonly, assign, nonatomic) NSUInteger cutIndex; // in [1, 36].

+ (instancetype)circleWithResultSet:(FMResultSet *)result;

@end
