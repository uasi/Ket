@class CatalogDatabase;
@class Circle;
@class CircleCollection;
@class CircleCutArchive;

@interface CircleDataProvider : NSObject

@property (nonatomic, readonly) CatalogDatabase *catalogDatabase;
@property (nonatomic, readonly) CircleCutArchive *circleCutArchive;

- (instancetype)initWithComiketNo:(NSUInteger)comiketNo;

- (NSInteger)numberOfRows;
- (CircleCollection *)circleCollectionForRow:(NSInteger)row;
- (NSString *)stringValueForGroupRow:(NSInteger)row;
- (BOOL)isGroupRow:(NSInteger)row;

@end
