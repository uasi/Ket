extern NSString *const ChecklistDidChangeNotification;

@class Circle;

@protocol ChecklistReading <NSObject>

@property (nonatomic, readonly) NSUInteger comiketNo;
@property (nonatomic, readonly) NSIndexSet *globalIDSet;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) id<ChecklistReading> snapshot;
@property (nonatomic, readonly) NSString *identifier;

- (BOOL)bookmarksContainsCircle:(Circle *)circle;
- (BOOL)bookmarksContainsCircleWithGlobalID:(NSUInteger)globalID;
- (NSString *)noteForCircle:(Circle *)circle;
- (NSString *)noteForCircleWithGlobalID:(NSUInteger)globalID;
- (NSInteger)colorCodeForCircle:(Circle *)circle;
- (NSInteger)colorCodeForCircleWithGlobalID:(NSUInteger)globalID;
- (NSColor *)colorForCircle:(Circle *)circle;
- (NSColor *)colorForCode:(NSInteger)colorCode;

@end

@protocol ChecklistWriting <NSObject>

- (void)setNote:(NSString *)note forCircle:(Circle *)circle;
- (void)setNote:(NSString *)note forCircleWithGlobalID:(NSUInteger)globalID;
- (void)setColorCode:(NSInteger)colorCode forCircle:(Circle *)circle;
- (void)setColorCode:(NSInteger)colorCode forCircleWithGlobalID:(NSUInteger)globalID;

@end

@interface Checklist : NSObject <NSCopying, ChecklistReading, ChecklistWriting>

- (instancetype)initWithComiketNo:(NSUInteger)comiketNo;
- (instancetype)initWithData:(NSData *)data error:(NSError **)error;

#ifdef DEBUG
- (NSMutableDictionary *)debug_entryForCircleWithGlobalID:(NSUInteger)globalID;
- (NSMutableDictionary *)debug_entries;
#endif

@end
