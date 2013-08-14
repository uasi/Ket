@class Circle;
@class CircleCollection;

@interface CatalogDatabase : NSObject

@property (nonatomic, readonly) NSInteger comiketNo;
@property (nonatomic, readonly) NSSize cutSizeForPrinting;
@property (nonatomic, readonly) NSPoint cutOriginForPrinting;
@property (nonatomic, readonly) NSUInteger numberOfCutsInRow;
@property (nonatomic, readonly) NSUInteger numberOfCutsInColumn;
@property (nonatomic, readonly) NSIndexSet *pageSet;

- (instancetype)initWithURL:(NSURL *)URL;

- (Circle *)circleForGlobalID:(NSUInteger)globalID;
- (NSArray *)circlesInPage:(NSUInteger)page;

- (NSDictionary *)dateInfoOfDay:(NSInteger)day;
- (NSString *)simpleAreaNameForBlockID:(NSInteger)blockID;
- (NSString *)blockNameForID:(NSInteger)blockID;

@end
