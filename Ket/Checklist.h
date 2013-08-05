@class Circle;

@protocol ChecklistReading

@property (nonatomic, readonly) NSUInteger comiketNo;
@property (nonatomic, readonly) NSIndexSet *globalIDSet;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) id<ChecklistReading> snapshot;
@property (nonatomic, readonly) NSString *tableName;

- (BOOL)bookmarksContainsCircle:(Circle *)circle;
- (BOOL)bookmarksContainsCircleWithGlobalID:(NSUInteger)globalID;

@end

@protocol ChecklistWriting

- (void)addCircleToBookmarks:(Circle *)circle;
- (void)removeCircleFromBookmarks:(Circle *)circle;

@end

@interface Checklist : NSObject <NSCopying, ChecklistReading, ChecklistWriting>

- (instancetype)initWithComiketNo:(NSUInteger)comiketNo;
- (instancetype)initWithData:(NSData *)data error:(NSError **)error;

@end
