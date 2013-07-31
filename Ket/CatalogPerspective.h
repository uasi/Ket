@class FMDatabase;

@interface CatalogPerspective : NSObject

@property (nonatomic, readonly) NSUInteger count;

- (instancetype)initWithDatabase:(FMDatabase *)database filter:(NSString *)filter;

- (NSArray *)circlesWithLimit:(NSUInteger)limit offset:(NSUInteger)offset;

@end
