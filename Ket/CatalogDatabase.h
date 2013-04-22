@class CircleCollection;

@interface CatalogDatabase : NSObject

@property (readonly, nonatomic) NSInteger comiketNo;
@property (readonly, nonatomic) NSSize cutSize;
@property (readonly, nonatomic) NSPoint cutOrigin;
@property (readonly, nonatomic) NSUInteger numberOfCutsInRow;
@property (readonly, nonatomic) NSUInteger numberOfCutsInColumn;
@property (readonly, strong, nonatomic) NSIndexSet *pageNoIndexSet;

+ (CatalogDatabase *)databaseWithContentsOfFile:(NSString *)file;

- (CircleCollection *)circleCollectionForPage:(NSUInteger)page;

- (NSString *)blockNameForID:(NSInteger)blockID;

@end
