#import "CatalogFilter.h"

#import "CatalogFilter+Parsing.h"

#import "CatalogDatabase.h"
#import "Checklist.h"
#import "ChecklistModule.h"
#import "NSRegularExpression+Extensions.h"
#import <FMDB/FMDatabase.h>

@interface CatalogDatabase (CatalogFilter_Private)

@property (nonatomic, readonly) FMDatabase *database;

@end

@interface CatalogFilter ()

@property (nonatomic, readwrite) NSString *selectStatement;

@property (nonatomic) CatalogDatabase *database;
@property (nonatomic) Checklist *checklist;
@property (nonatomic) NSString *string;

@property (nonatomic, readonly) NSString *tableName;

@end

@implementation CatalogFilter

+ (CatalogFilter *)filterWithDatabase:(CatalogDatabase *)database checklist:(Checklist *)checklist string:(NSString *)string
{
  NSArray *arrayOfProperties = [self arrayOfFilterPropertiesByParsingString:string];
  if (arrayOfProperties.count == 0) {
    return [CatalogFilter passthroughFilter];
  }

  CatalogFilter *filter = [[CatalogFilter alloc] init];
  filter.database = database;
  filter.checklist = checklist;
  filter.string = string;
  NSString *partialStatement;
  NSPredicate *requiresChecklist = [NSPredicate predicateWithFormat:@"ANY requiresChecklist == TRUE"];
  if ([requiresChecklist evaluateWithObject:arrayOfProperties]) {
    [filter createChecklistTable];
    NSNumber *boxedJoinType = [arrayOfProperties valueForKeyPath:@"@max.joinType"];
    CatalogFilterJoinType joinType = (CatalogFilterJoinType)[boxedJoinType integerValue];
    NSString *join = CatalogFilterJoinStringWithType(joinType);
    static NSString *sqlFormat = (@"SELECT * FROM ComiketCircle"
                                  @"  %1$@ JOIN %2$@"
                                  @"  ON ComiketCircle.id = %2$@.id");
    partialStatement = [NSString stringWithFormat:sqlFormat, join, filter.tableName];
  }
  else {
    partialStatement = @"SELECT * FROM ComiketCircle";
  }
  NSArray *constraints = [arrayOfProperties valueForKeyPath:@"constraint"];
  filter.selectStatement = [NSString stringWithFormat:@"%@ WHERE pageNo > 0 AND %@",
                            partialStatement,
                            [constraints componentsJoinedByString:@" AND "]];
  return filter;
}

+ (CatalogFilter *)passthroughFilter
{
  static CatalogFilter *passthroughFilter;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    passthroughFilter = [[CatalogFilter alloc] init];
    passthroughFilter.selectStatement = @"SELECT * FROM ComiketCircle WHERE pageNo > 0";
  });
  return passthroughFilter;
}

- (void)dealloc
{
  [self dropChecklistTable];
}

- (void)createChecklistTable
{
  NSAssert(self.checklist, @"self.checklist must not be nil");
  ChecklistModuleRegisterChecklistWeakRef(self.checklist);
  NSString *sql = [NSString stringWithFormat:
                   @"CREATE VIRTUAL TABLE IF NOT EXISTS main.%@ USING %@ (%@);",
                   self.tableName,
                   ChecklistModuleName(),
                   self.checklist.identifier];
  BOOL ok = [self.database.database executeUpdate:sql];
  NSAssert(ok, @"CREATE VIRTUAL TABLE must succeed: %@", self.database.database.lastError);
}

- (void)dropChecklistTable
{
  if (!self.checklist) return;
  NSString *sql = [NSString stringWithFormat:
                   @"DROP TABLE IF EXISTS main.%@",
                   self.tableName];
  BOOL ok = [self.database.database executeUpdate:sql];
  NSAssert(ok, @"DROP TABLE must succeed: %@", self.database.database.lastError);
}

- (NSString *)tableName
{
  return [NSString stringWithFormat:@"%@_%tx",
          NSStringFromClass([self class]),
          (void *)self];
}

@end
