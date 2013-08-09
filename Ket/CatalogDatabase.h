@class Circle;
@class CircleCollection;

@interface CatalogDatabase : NSObject

@property (nonatomic, readonly) NSInteger comiketNo;
@property (nonatomic, readonly) NSSize cutSize DO_NOT_USE("cutSize is for printing purposes, which Ket doesn't support");
@property (nonatomic, readonly) NSPoint cutOrigin DO_NOT_USE("cutOrigin is for printing purposes, which Ket dosn't support");
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
