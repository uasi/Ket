#import "CSVChecklistV2Reader.h"

#import "CSVChecklistV2Scanner.h"
#import "Checklist.h"
#import "Circle.h"
#import "PathUtils.h"

@interface CSVChecklistV2Reader () <CSVChecklistV2ScannerDelegate>

@property (nonatomic) Checklist *checklist;
@property (nonatomic) NSError *error;
@property (nonatomic) NSUInteger recordIndex;
@property (nonatomic) NSUInteger fieldIndex;
@property (nonatomic) NSMutableArray *fields;

@end

@implementation CSVChecklistV2Reader

+ (Checklist *)checklistWithContentsOfURL:(NSURL *)URL error:(NSError **)error
{
  NSString *string = [NSString stringWithContentsOfURL:URL usedEncoding:NULL error:NULL];
  CSVChecklistV2Scanner *scanner = [[CSVChecklistV2Scanner alloc] initWithString:string];
  CSVChecklistV2Reader *reader = [[CSVChecklistV2Reader alloc] init];
  scanner.delegate = reader;
  [scanner scan];
  if (reader.error) {
    if (error) *error = reader.error;
    return nil;
  }
  return reader.checklist;
}

- (instancetype)init
{
  self = [super init];
  if (!self) return nil;
  self.fields = [NSMutableArray array];
  return self;
}

#pragma mark CSVChecklistV2ScannerDelegate Protocol

static NSInteger integerFromString(NSString *string) {
  NSInteger integer = 0;
  [[NSScanner scannerWithString:string] scanInteger:&integer];
  return integer;
}

- (void)checklistScannerDidScanRecord:(CSVChecklistV2Scanner *)scanner
{
  if (self.recordIndex == 0) {
    NSUInteger comiketNo = 0;
    if (self.fields.count > 2) {
      NSString *comiketLongName = self.fields[2]; // expects a string like "ComicMarket99"
      comiketNo = ComiketNoFromString(comiketLongName);
    }
    if (comiketNo > 0) {
      self.checklist = [[Checklist alloc] initWithComiketNo:comiketNo];
    }
    else {
      // Bail out.
      scanner.delegate = nil;
      // XXX: make some noise!
      // self.error = [NSError ...];
      return;
    }
  }
  else {
    if (self.fields.count > 3) {
      NSUInteger circleID = integerFromString(self.fields[1]);
      NSInteger colorCode = integerFromString(self.fields[2]);
      if (circleID) {
        NSUInteger globalID = GlobalCircleIDMake(self.checklist.comiketNo, circleID);
        [self.checklist setColorCode:colorCode forCircleWithGlobalID:globalID];
      }
    }
  }

  self.recordIndex++;
  self.fieldIndex = 0;
  [self.fields removeAllObjects];
}

// XXX: make this be a member of the protocol and make the scanner call this
- (void)checklistScannerDidScanCSV:(CSVChecklistV2Scanner *)scanner
{
  if (self.recordIndex == 0) {
    // XXX: raise error
  }
}

- (void)checklistScanner:(CSVChecklistV2Scanner *)scanner didScanFieldWithStringValue:(NSString *)stringValue
{
  if (self.recordIndex == 0) return;
  self.fieldIndex++;
  [self.fields addObject:stringValue];
}

@end
