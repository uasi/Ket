@class CircleCollection;

@interface CatalogDatabase : NSObject

@property (nonatomic, readonly) NSInteger comiketNo;
@property (nonatomic, readonly) NSSize cutSize __attribute__((deprecated));
@property (nonatomic, readonly) NSPoint cutOrigin __attribute__((deprecated));
@property (nonatomic, readonly) NSUInteger numberOfCutsInRow;
@property (nonatomic, readonly) NSUInteger numberOfCutsInColumn;
@property (nonatomic, readonly) NSIndexSet *pageNoIndexSet;

- (instancetype)initWithURL:(NSURL *)URL;

- (CircleCollection *)circleCollectionForPage:(NSUInteger)page;

- (NSString *)blockNameForID:(NSInteger)blockID;

@end
