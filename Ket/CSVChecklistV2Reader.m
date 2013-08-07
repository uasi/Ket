#import "CSVChecklistV2Reader.h"

#import "CSVChecklistV2Scanner.h"

@interface CSVChecklistV2Reader () <CSVChecklistV2ScannerDelegate>

@property (nonatomic) Checklist *checklist;
@property (nonatomic) NSUInteger recordIndex;
@property (nonatomic) NSUInteger fieldIndex;
@property (nonatomic) NSMutableArray *fields;

@end

@implementation CSVChecklistV2Reader

+ (Checklist *)checklistWithContentsOfURL:(NSURL *)URL
{
  NSString *string = [NSString stringWithContentsOfURL:URL usedEncoding:NULL error:NULL];
  CSVChecklistV2Scanner *scanner = [[CSVChecklistV2Scanner alloc] initWithString:string];
  CSVChecklistV2Reader *reader = [[CSVChecklistV2Reader alloc] init];
  scanner.delegate = reader;
  [scanner scan];
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

- (void)checklistScannerWillScanRecord:(CSVChecklistV2Scanner *)scanner
{
}

- (void)checklistScannerDidScanRecord:(CSVChecklistV2Scanner *)scanner
{
  self.recordIndex++;
  self.fieldIndex = 0;
  [self.fields removeAllObjects];
}

- (void)checklistScannerWilScanField:(CSVChecklistV2Scanner *)scanner
{
}

- (void)checklistScanner:(CSVChecklistV2Scanner *)scanner didScanFieldWithStringValue:(NSString *)stringValue
{
  if (self.recordIndex == 0) return;
  self.fieldIndex++;
  [self.fields addObject:stringValue];
}

@end
