#import "CSVChecklistV2Writer.h"

#import "CatalogDatabase.h"
#import "Checklist.h"
#import "Circle.h"
#import "ConversionUtils.h"

static const NSUInteger kBufferCapacity = 64 * 1024;
static NSString *const kKetVersionString = @"Ket 1.0.0 Compatible";

@interface CSVChecklistV2Writer ()

@property (nonatomic) Checklist *checklist;
@property (nonatomic) CatalogDatabase *database;
@property (nonatomic) NSMutableString *buffer;

@end

@implementation CSVChecklistV2Writer

+ (BOOL)writeChecklist:(Checklist *)checklist withDatabase:(CatalogDatabase *)database toURL:(NSURL *)URL error:(NSError **)error
{
  NSString *string = [self stringRepresentationOfChecklist:checklist withDatabase:(CatalogDatabase *)database];
  START_ACCESSING_RESOURCE_WITHIN_SCOPE(URL);
  return [string writeToURL:URL atomically:YES encoding:NSUTF8StringEncoding error:error];
}

+ (NSString *)stringRepresentationOfChecklist:(Checklist *)checklist withDatabase:(CatalogDatabase *)database
{
  NSMutableString *buffer = [NSMutableString stringWithCapacity:kBufferCapacity];
  [buffer appendString:[self headerRecordWithChecklist:checklist]];
  [checklist.globalIDSet enumerateIndexesUsingBlock:^(NSUInteger globalID, BOOL *stop) {
    Circle *circle = [database circleForGlobalID:globalID];
    if (circle) {
      [buffer appendString:[self circleRecordForCircle:circle withChecklist:checklist database:database]];
    }
  }];
  return [buffer copy];
}

+ (NSString *)headerRecordWithChecklist:(Checklist *)checklist
{
  return [NSString stringWithFormat:
          @"Header,ComicMarketCD-ROMCatalog,ComicMarket%lu,UTF-8,%@\n",
          (unsigned long)checklist.comiketNo,
          kKetVersionString];
}

+ (NSString *)circleRecordForCircle:(Circle *)circle withChecklist:(Checklist *)checklist database:(CatalogDatabase *)database
{
  static NSString *format = (@"Circle,%lu,%lu,%lu,%lu," // column  1 to  5
                             @"%@,%@,%@,%lu,%lu,"       // column  6 to 10
                             @"%@,%@,%@,%@,%@,"         // column 11 to 15
                             @"%@,%@,%@,%ld,%ld,"       // column 16 to 20
                             @"%ld,%@,%@,%@,%@\n");     // column 21 to 15
  return [NSString stringWithFormat:
          format,
          // Column 2 to 5
          (unsigned long)circle.updateID,
          (unsigned long)[checklist colorCodeForCircle:circle],
          (unsigned long)circle.page,
          (unsigned long)circle.cutIndex,
          // Column 6 to 10
          WeekdayKanjiFromInteger(((NSNumber *)[database dateInfoOfDay:circle.day][@"weekday"] ?: @1).integerValue),
          [database simpleAreaNameForBlockID:circle.blockID],
          [database blockNameForID:circle.blockID],
          (unsigned long)circle.space,
          (unsigned long)circle.genreID,
          // Column 11 to 15
          circle.circleName,
          circle.circleKana, // XXX: convert half width katakana to full width
          circle.author,
          circle.title,
          circle.URL.absoluteString ?: @"",
          // Column 16 to 20
          circle.mailAddress,
          circle.circleDescription,
          @"", // XXX: user's notes
          (long)0, // XXX: circle position.X
          (long)0, // XXX: circle position.Y
          // Column 21 to 25
          ((unsigned long)circle.spaceSub + 1),
          @"", // XXX: update info
          circle.circlemsURL.absoluteString ?: @"",
          circle.RSSURL.absoluteString ?: @"",
          @"" // XXX: rss update info
          ];
}

@end
