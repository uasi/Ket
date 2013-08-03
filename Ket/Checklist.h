@class Circle;

@interface Checklist : NSObject

- (instancetype)initWithComiketNo:(NSUInteger)comiketNo;
- (instancetype)initWithData:(NSData *)data error:(NSError **)error;

- (void)addCircleToBookmarks:(Circle *)circle;
- (void)removeCircleFromBookmarks:(Circle *)circle;
- (BOOL)bookmarksContainsCircle:(Circle *)circle;
- (NSData *)data;

@end
