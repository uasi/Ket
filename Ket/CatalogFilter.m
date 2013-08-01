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

- (instancetype)initWithString:(NSString *)string
{
  self = [super init];
  if (!self) return nil;

  self.filterString = string;
  self.selectStatement = @"SELECT * FROM ComiketCircle"; // XXX: build sane select statement...

  return self;
}

@end
