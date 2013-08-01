#import "CatalogFilter.h"

@interface CatalogFilter ()

@property (nonatomic) NSString *filterString;

@end

@implementation CatalogFilter

- (instancetype)initWithString:(NSString *)string
{
  self = [super init];
  if (!self) return nil;

  self.filterString = string;

  return self;
}

- (NSString *)selectStatement
{
  return @"SELECT * FROM ComiketCircle";
}

@end
