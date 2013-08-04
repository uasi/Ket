#import "CatalogFilter.h"

@interface CatalogFilter ()

@property (nonatomic, readwrite) NSString *selectStatement;

@property (nonatomic) NSString *filterString;

@end

@implementation CatalogFilter

+ (CatalogFilter *)passthroughFilter
{
  static CatalogFilter *passthroughFilter;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    passthroughFilter = [[CatalogFilter alloc] initWithString:@""];
    passthroughFilter.selectStatement = @"SELECT * FROM ComiketCircle";
  });
  return passthroughFilter;
}

+ (CatalogFilter *)filterWithString:(NSString *)string
{
  if (!string || [string isEqualToString:@""]) {
    return [self passthroughFilter];
  }
  return [[self alloc] initWithString:string];
}

static NSString *sqlEscape(NSString *string)
{
  string = [string stringByReplacingOccurrencesOfString:@"$" withString:@"$$"];
  string = [string stringByReplacingOccurrencesOfString:@"%" withString:@"$%"];
  string = [string stringByReplacingOccurrencesOfString:@"_" withString:@"$_"];
  string = [string stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
  return [NSString stringWithFormat:@"%%%@%%", string];
}

- (instancetype)initWithString:(NSString *)string
{
  self = [super init];
  if (!self) return nil;

  self.filterString = string;

  NSString *sqlFormat = (@"SELECT * FROM ComiketCircle"
                         @"  WHERE pageNo > 0 AND description LIKE '%@'"
                         @"  ESCAPE '$'");
  self.selectStatement = [NSString stringWithFormat:
                          sqlFormat,
                          sqlEscape(string)];

  return self;
}

@end
