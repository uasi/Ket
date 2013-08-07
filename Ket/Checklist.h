extern NSString *ChecklistDidChangeNotification;

@class Circle;

@protocol ChecklistReading

@property (nonatomic, readonly) NSUInteger comiketNo;
@property (nonatomic, readonly) NSIndexSet *globalIDSet;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) id<ChecklistReading> snapshot;
@property (nonatomic, readonly) NSString *identifier;

- (BOOL)bookmarksContainsCircle:(Circle *)circle;
- (BOOL)bookmarksContainsCircleWithGlobalID:(NSUInteger)globalID;
- (NSColor *)colorForCircle:(Circle *)circle;
- (NSInteger)colorCodeForCircle:(Circle *)circle;
- (NSColor *)colorForCode:(NSInteger)colorCode;

@end

@protocol ChecklistWriting

// XXX: use setColorCode:forCircle: for marking a circle.
- (void)addCircleToBookmarks:(Circle *)circle __deprecated;
- (void)removeCircleFromBookmarks:(Circle *)circle __deprecated;

- (void)setColorCode:(NSInteger)colorCode forCircle:(Circle *)circle;

@end

@interface Checklist : NSObject <NSCopying, ChecklistReading, ChecklistWriting>

- (instancetype)initWithComiketNo:(NSUInteger)comiketNo;
- (instancetype)initWithData:(NSData *)data error:(NSError **)error;

@end
