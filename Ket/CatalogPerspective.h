@class CatalogDatabase;
@class CircleCollection;

@interface CatalogPerspective : NSObject

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSUInteger numberOfCircles;
@property (nonatomic, readonly) NSUInteger numberOfCircleCollections;

- (instancetype)initWithDatabase:(CatalogDatabase *)database;

- (NSUInteger)pageAtIndex:(NSUInteger)index;
- (CircleCollection *)circleCollectionAtIndex:(NSUInteger)index;

@end
