@class CircleCollection;

@interface CatalogDatabase : NSObject

@property (nonatomic, readonly) NSInteger comiketNo;
@property (nonatomic, readonly) NSSize cutSize;
@property (nonatomic, readonly) NSPoint cutOrigin;
@property (nonatomic, readonly) NSUInteger numberOfCutsInRow;
@property (nonatomic, readonly) NSUInteger numberOfCutsInColumn;
@property (nonatomic, readonly) NSIndexSet *pageNoIndexSet;

+ (CatalogDatabase *)databaseWithContentsOfURL:(NSURL *)URL;

- (CircleCollection *)circleCollectionForPage:(NSUInteger)page;

- (NSString *)blockNameForID:(NSInteger)blockID;

@end
