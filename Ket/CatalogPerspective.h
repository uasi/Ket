@class CatalogDatabase;
@class CatalogFilter;
@class CircleCollection;

@interface CatalogPerspective : NSObject

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSUInteger numberOfCircles;
@property (nonatomic, readonly) NSUInteger numberOfCirclesPerCollection;
@property (nonatomic, readonly) NSUInteger numberOfCircleCollections;


+ (CatalogPerspective *)perspectiveWithDatabase:(CatalogDatabase *)database;
+ (CatalogPerspective *)perspectiveWithDatabase:(CatalogDatabase *)database filter:(CatalogFilter *)filter;

- (NSUInteger)pageAtIndex:(NSUInteger)index;
- (CircleCollection *)circleCollectionAtIndex:(NSUInteger)index;

@end
