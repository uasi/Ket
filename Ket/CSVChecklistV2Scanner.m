#import "CSVChecklistV2Scanner.h"

@interface CSVChecklistV2Scanner ()

@property (nonatomic, readwrite) NSString *string;
@property (nonatomic, readwrite) NSUInteger location;

@end

@implementation CSVChecklistV2Scanner

- (instancetype)initWithString:(NSString *)string
{
  self = [super init];
  if (!self) return nil;
  self.string = string;
  return self;
}

- (BOOL)isAtEnd
{
  return self.location >= self.string.length;
}

- (void)scan
{
  while (![self isAtEnd]) {
    [self scanRecord];
  }
}

- (void)scanRecord
{
  [self willScanRecord];

  while (1) {
    if ([self isAtEnd]) {
      break;
    }
    else if ([self remainingStringHasPrefix:@","]) {
      self.location += 1;
    }
    else if ([self remainingStringHasPrefix:@"\r\n"]) {
      self.location += 2;
      break;
    }
    else if ([self remainingStringHasPrefix:@"\r"] || [self remainingStringHasPrefix:@"\n"]) {
      self.location += 1;
      break;
    }
    else {
      [self scanField];
    }
  }

  [self didScanRecord];
}

- (void)scanField
{
  [self willScanField];

  NSString *string;
  if ([self remainingStringHasPrefix:@"\""]) {
    string = [self stringByScanningQuotedField];
  }
  else {
    string = [self stringByScanningBareField];
  }

  [self didScanFieldWithStringValue:string];
}

- (NSString *)stringByScanningBareField
{
  static NSCharacterSet *terminators;
  if (!terminators) terminators = [NSCharacterSet characterSetWithCharactersInString:@",\r\n"];

  NSScanner *scanner = [NSScanner scannerWithString:self.string];
  scanner.charactersToBeSkipped = nil;
  scanner.scanLocation = self.location;
  [scanner scanUpToCharactersFromSet:terminators intoString:NULL];

  NSRange range = NSMakeRange(self.location, scanner.scanLocation - self.location);
  NSString *string = [self.string substringWithRange:range];
  self.location = scanner.scanLocation;

  return string;
}

- (NSString *)stringByScanningQuotedField
{
  static NSCharacterSet *quote;
  if (!quote) quote = [NSCharacterSet characterSetWithCharactersInString:@"\""];

  // Start scanning from next to the opening quote.
  self.location += 1;
  NSUInteger startLocation = self.location;

  NSScanner *scanner = [NSScanner scannerWithString:self.string];
  scanner.charactersToBeSkipped = nil;
  scanner.scanLocation = startLocation;
  while (1) {
    [scanner scanUpToCharactersFromSet:quote intoString:NULL];
    self.location = scanner.scanLocation;
    if ([self remainingStringHasPrefix:@"\"\""]) {
      // We encountered an escaped double quote; continue to scan beyond it.
      scanner.scanLocation += 2;
      continue;
    }
    break;
  }

  // Skip the closing double quote. Be careful, the quoted field might illegally
  // be terminated by the end of the entire string.
  self.location = scanner.scanLocation + ([self isAtEnd] ? 0 : 1);

  NSRange range = NSMakeRange(startLocation, scanner.scanLocation - startLocation);
  NSString *string = [self.string substringWithRange:range];

  return string;
}

- (BOOL)remainingStringHasPrefix:(NSString *)prefix
{
  NSUInteger length = MIN(prefix.length, self.string.length - self.location);
  NSRange range = NSMakeRange(self.location, length);
  return [[self.string substringWithRange:range] isEqualToString:prefix];
}

#pragma mark Delegation

- (void)willScanRecord
{
  if ([self.delegate respondsToSelector:@selector(checklistScannerWillScanRecord:)]) {
    [self.delegate checklistScannerWillScanRecord:self];
  }
}

- (void)didScanRecord
{
  if ([self.delegate respondsToSelector:@selector(checklistScannerDidScanRecord:)]) {
    [self.delegate checklistScannerDidScanRecord:self];
  }
}

- (void)willScanField
{
  if ([self.delegate respondsToSelector:@selector(checklistScannerWilScanField:)]) {
    [self.delegate checklistScannerWilScanField:self];
  }
}

- (void)didScanFieldWithStringValue:(NSString *)stringValue
{
  if ([self.delegate respondsToSelector:@selector(checklistScanner:didScanFieldWithStringValue:)]) {
    [self.delegate checklistScanner:self didScanFieldWithStringValue:stringValue];
  }
}

@end
