#import "ConversionUtils.h"

NSString *WeekdayKanjiFromInteger(NSInteger integer)
{
  NSCAssert(1 <= integer && integer <= 7, @"integer must be between 1 and 7");
  return @[@"日", @"月", @"火", @"水", @"木", @"金", @"土"][integer - 1];
}

NSString *ComiketIDFromComiketNo(NSUInteger comiketNo)
{
  NSCAssert(1 <= comiketNo && comiketNo <= 999, @"comiketNo must be in [1, 999]");
  return [NSString stringWithFormat:@"C%03d", (int)comiketNo];
}

NSString *ComiketNameFromComiketNo(NSUInteger comiketNo)
{
  NSCAssert(1 <= comiketNo && comiketNo <= 999, @"comiketNo must be in [1, 999]");
  return [NSString stringWithFormat:@"C%02d", (int)comiketNo];
}

NSUInteger ComiketNoFromString(NSString *comiketNameOrID)
{
  NSInteger comiketNo;
  NSScanner *scanner = [NSScanner scannerWithString:comiketNameOrID];
  scanner.charactersToBeSkipped = [NSCharacterSet letterCharacterSet];
  BOOL ok = [scanner scanInteger:&comiketNo];
  return (NSUInteger)(ok ? comiketNo : 0);
}