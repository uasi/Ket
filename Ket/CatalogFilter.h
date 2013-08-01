@interface CatalogFilter : NSObject

@property (nonatomic, readonly) NSString *selectStatement;

+ (CatalogFilter *)passthroughFilter;
+ (CatalogFilter *)filterWithString:(NSString *)string;

@end
