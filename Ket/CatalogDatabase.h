@interface CatalogDatabase : NSObject

@property (readonly, nonatomic) NSInteger comiketNo;
@property (readonly, nonatomic) NSSize cutSize;
@property (readonly, nonatomic) NSPoint cutOrigin;
@property (readonly, nonatomic) NSUInteger numberOfCutsInRow;
@property (readonly, nonatomic) NSUInteger numberOfCutsInColumn;
@property (readonly, strong, nonatomic) NSIndexSet *pageNoIndexSet;

+ (CatalogDatabase *)databaseWithContentsOfFile:(NSString *)file;

- (NSArray *)circlesInPage:(NSUInteger)page;
- (NSArray *)circlesInPagePaddedWithNull:(NSUInteger)page;

@end
