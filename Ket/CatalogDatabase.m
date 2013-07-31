#import "CatalogDatabase.h"

#import "CatalogPerspective.h"
#import "Circle.h"
#import "CircleCollection.h"
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseAdditions.h>
#import <FMDB/FMResultSet.h>
#import <sqlite3.h>

static const NSUInteger kNumberOfCutsInRow = 6;
static const NSUInteger kNumberOfCutsInColmun = 6;
static const NSUInteger kNumberOfCutsInPage = kNumberOfCutsInRow * kNumberOfCutsInColmun;

@interface CatalogDatabase ()

@property (nonatomic) FMDatabase *database;

@end

@implementation CatalogDatabase

@synthesize pageSet = _pageSet;

- (instancetype)initWithURL:(NSURL *)URL
{
  self = [super init];
  if (!self) return nil;

  self.database = [FMDatabase databaseWithPath:URL.path];
  if (![self.database openWithFlags:SQLITE_OPEN_READONLY]) return nil;

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
  return kNumberOfCutsInRow;
}

- (NSUInteger)numberOfCutsInColumn
{
  return kNumberOfCutsInColmun;
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

- (NSArray *)circlesInPage:(NSUInteger)page
{
  NSMutableArray *circles = [NSMutableArray arrayWithCapacity:kNumberOfCutsInPage];

  NSString *query = (@"SELECT * FROM ComiketCircle"
                     @"  WHERE pageNo = (?)"
                     @"  ORDER BY cutIndex ASC;");
  FMResultSet *result = [self.database executeQuery:query, [NSNumber numberWithUnsignedInteger:page]];
  while ([result next]) {
    [circles addObject:[Circle circleWithResultSet:result]];
  }

  return [circles copy];
}

- (CircleCollection *)circleCollectionForPage:(NSUInteger)page
{
  NSArray *circles = [self circlesInPage:page];
  return [[CircleCollection alloc] initWithCircles:circles cutCountPerPage:kNumberOfCutsInPage];
}

- (NSString *)blockNameForID:(NSInteger)blockID
{
  static NSArray *blockIDToBlockName;
  if (!blockIDToBlockName) {
    blockIDToBlockName =
    @[@"A",
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

  return blockIDToBlockName[blockID - 1];
}

- (CatalogPerspective *)perspective
{
  return [[CatalogPerspective alloc] initWithDatabase:self];
}

@end
