#import "CatalogFilter.h"

typedef NS_ENUM(NSInteger, CatalogFilterJoinType) {
  CatalogFilterJoinTypeInner = 1,
  CatalogFilterJoinTypeLeftOuter = 2,
};

NSString *CatalogFilterJoinStringWithType(CatalogFilterJoinType joinType);

@interface CatalogFilter (Parsing)

+ (NSArray *)arrayOfFilterPropertiesByParsingString:(NSString *)string;

@end