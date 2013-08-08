#import "CatalogDatabase.h"

#import "ChecklistModule.h"
#import "Circle.h"
#import "CircleCollection.h"
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseAdditions.h>
#import <FMDB/FMResultSet.h>
#import <sqlite3.h>

static const NSUInteger kNumberOfCutsPerRow = 6;
static const NSUInteger kNumberOfCutsPerColmun = 6;
static const NSUInteger kNumberOfCutsPerPage = kNumberOfCutsPerRow * kNumberOfCutsPerColmun;

@interface CatalogDatabase ()

@property (nonatomic) FMDatabase *database;

@end

@implementation CatalogDatabase

@synthesize pageSet = _pageSet;

+ (void)load
{
  sqlite3_config(SQLITE_CONFIG_URI, 1);
}

- (instancetype)initWithURL:(NSURL *)URL
{
  self = [super init];
  if (!self) return nil;

  // Here we create a writable in-memory database at first, then attach a
  // read-only database to it. This enables us to execute a statement which has
  // a side effect.
  // If we do the opposite - in other words if we open a read-only database and
  // then attach a writable database, we will not be able to execute such a
  // statement even on the writable one. This is supposedly because the SQLite
  // engine tries to aquire a mutex or something in the main database
  // (which is read-only in this case).

  self.database = [FMDatabase databaseWithPath:@":memory:"];
  if (![self.database open]) return nil;

  NSString *URLString = [URL.absoluteString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
  static NSString *sqlFormat = @"ATTACH DATABASE '%@?mode=ro' AS Comiket;";
  NSString *sql = [NSString stringWithFormat:sqlFormat, URLString];
  if (![self.database executeUpdate:sql]) return nil;

  int rc = ChecklistModuleInit(self.database.sqliteHandle);
  NSAssert(rc == SQLITE_OK, @"ChecklistModuleInit() must succeed: %@", self.database.lastError);
  if (rc != SQLITE_OK) return nil;

  return self;
}

- (instancetype)init
{
  @throw NSInternalInconsistencyException;
}

- (void)dealloc
{
  [self.database close];
}

- (NSInteger)comiketNo
{
  return [self.database intForQuery:@"SELECT comiketNo FROM ComiketInfo;"];
}

- (NSSize)cutSize
{
  CGFloat w = [self.database intForQuery:@"SELECT cutSizeW FROM ComiketInfo;"];
  CGFloat h = [self.database intForQuery:@"SELECT cutSizeH FROM ComiketInfo;"];
  return NSMakeSize(w, h);
}

- (NSPoint)cutOrigin
{
  CGFloat x = [self.database intForQuery:@"SELECT cutOriginX FROM ComiketInfo"];
  CGFloat y = [self.database intForQuery:@"SELECT cutOriginY FROM ComiketInfo"];
  return NSMakePoint(x, y);
}

- (NSUInteger)numberOfCutsInRow
{
  return kNumberOfCutsPerRow;
}

- (NSUInteger)numberOfCutsInColumn
{
  return kNumberOfCutsPerColmun;
}

- (NSIndexSet *)pageSet
{
  if (_pageSet) return _pageSet;

  NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];

  NSString *query = (@"SELECT DISTINCT pageNo FROM ComiketCircle"
                     @"  WHERE pageNo > 0"
                     @"  ORDER BY pageNo ASC;");
  FMResultSet *result = [self.database executeQuery:query];
  while ([result next]) {
    [indexSet addIndex:[result intForColumnIndex:0]];
  }

  return _pageSet = [indexSet copy];
}

- (Circle *)circleForGlobalID:(NSUInteger)globalID
{
  NSUInteger circleID = CircleIdentifierFromGlobalCircleID(globalID);
  NSString *sql = @"SELECT * FROM ComiketCircle WHERE id = (?)";
  FMResultSet *result = [self.database executeQuery:sql, @(circleID)];
  if (![result next]) return nil;
  return [Circle circleWithResultSet:result];
}

- (NSArray *)circlesInPage:(NSUInteger)page
{
  NSMutableArray *circles = [NSMutableArray arrayWithCapacity:kNumberOfCutsPerPage];

  NSString *query = (@"SELECT * FROM ComiketCircle"
                     @"  WHERE pageNo = (?)"
                     @"  ORDER BY cutIndex ASC;");
  FMResultSet *result = [self.database executeQuery:query, [NSNumber numberWithUnsignedInteger:page]];
  while ([result next]) {
    [circles addObject:[Circle circleWithResultSet:result]];
  }

  return [circles copy];
}

- (NSDictionary *)dateInfoOfDay:(NSInteger)day
{
  NSString *sql = @"SELECT * FROM ComiketDate WHERE id = (?)";
  FMResultSet *result = [self.database executeQuery:sql, @(day)];
  NSMutableDictionary *dateInfo = [NSMutableDictionary dictionary];
  if (![result next]) return nil;
  dateInfo[@"year"] = @([result intForColumn:@"year"]);
  dateInfo[@"month"] = @([result intForColumn:@"month"]);
  dateInfo[@"day"] = @([result intForColumn:@"day"]);
  dateInfo[@"weekday"] = @([result intForColumn:@"weekday"]);
  return [dateInfo copy];
}

- (NSString *)simpleAreaNameForBlockID:(NSInteger)blockID
{
  NSString *sql = (@"SELECT simpleName FROM ComiketArea"
                   @"  INNER JOIN ComiketBlock"
                   @"  ON ComiketArea.id = ComiketBlock.areaId"
                   @"  WHERE ComiketBlock.id = (?)");
  FMResultSet *result = [self.database executeQuery:sql, @(blockID)];
  if (![result next]) return nil;
  return [result stringForColumn:@"simpleName"];
}

- (NSString *)blockNameForID:(NSInteger)blockID
{
  static NSArray *blockIDToBlockName;
  if (!blockIDToBlockName) {
    blockIDToBlockName =
    @[@"*",
      @"A",
      @"B",
      @"C",
      @"D",
      @"E",
      @"F",
      @"G",
      @"H",
      @"I",
      @"J",
      @"K",
      @"L",
      @"M",
      @"N",
      @"O",
      @"P",
      @"Q",
      @"R",
      @"S",
      @"T",
      @"U",
      @"V",
      @"W",
      @"X",
      @"Y",
      @"Z",
      @"ア",
      @"イ",
      @"ウ",
      @"エ",
      @"オ",
      @"カ",
      @"キ",
      @"ク",
      @"ケ",
      @"コ",
      @"サ",
      @"シ",
      @"ス",
      @"セ",
      @"ソ",
      @"タ",
      @"チ",
      @"ツ",
      @"テ",
      @"ト",
      @"ナ",
      @"ニ",
      @"ヌ",
      @"ネ",
      @"ノ",
      @"ハ",
      @"パ",
      @"ヒ",
      @"ピ",
      @"フ",
      @"プ",
      @"ヘ",
      @"ペ",
      @"ホ",
      @"ポ",
      @"マ",
      @"ミ",
      @"ム",
      @"メ",
      @"モ",
      @"ヤ",
      @"ユ",
      @"ヨ",
      @"ラ",
      @"リ",
      @"ル",
      @"レ",
      @"ロ",
      @"あ",
      @"い",
      @"う",
      @"え",
      @"お",
      @"か",
      @"き",
      @"く",
      @"け",
      @"こ",
      @"さ",
      @"し",
      @"す",
      @"せ",
      @"そ",
      @"た",
      @"ち",
      @"つ",
      @"て",
      @"と",
      @"な",
      @"に",
      @"ぬ",
      @"ね",
      @"の",
      @"は",
      @"ひ",
      @"ふ",
      @"へ",
      @"ほ",
      @"ま",
      @"み",
      @"む",
      @"め",
      @"も",
      @"や",
      @"ゆ",
      @"よ",
      @"ら",
      @"り",
      @"る",
      @"れ"];
  }

  return blockIDToBlockName[blockID];
}

@end
