@class CatalogDatabase;
@class Checklist;

@interface CatalogFilter : NSObject

@property (nonatomic, readonly) NSString *selectStatement;

+ (CatalogFilter *)filterWithDatabase:(CatalogDatabase *)database checklist:(Checklist *)checklist string:(NSString *)string;
+ (CatalogFilter *)passthroughFilter;

@end
