@class Circle;

@protocol ChecklistReading

@property (nonatomic, readonly) NSUInteger comiketNo;
@property (nonatomic, readonly) NSOrderedSet *orderedGlobalIDSet;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) id<ChecklistReading> snapshot;

- (BOOL)bookmarksContainsCircle:(Circle *)circle;

@end

@protocol ChecklistWriting

- (void)addCircleToBookmarks:(Circle *)circle;
- (void)removeCircleFromBookmarks:(Circle *)circle;

@end

@interface Checklist : NSObject <NSCopying, ChecklistReading, ChecklistWriting>

- (instancetype)initWithComiketNo:(NSUInteger)comiketNo;
- (instancetype)initWithData:(NSData *)data error:(NSError **)error;

@end
