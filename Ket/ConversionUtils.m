#import "ConversionUtils.h"

NSString *WeekdayKanjiFromInteger(NSInteger integer)
{
  NSCAssert(1 <= integer && integer <= 7, @"integer must be between 1 and 7");
  return @[@"日", @"月", @"火", @"水", @"木", @"金", @"土"][integer - 1];
}
