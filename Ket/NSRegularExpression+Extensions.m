#import "NSRegularExpression+Extensions.h"

@implementation NSRegularExpression (Extensions)

+ (BOOL)testString:(NSString *)subject withPattern:(NSString *)pattern
{
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
  if (!regex) return NO;
  return [regex testString:subject];
}

- (BOOL)testString:(NSString *)subject
{
  return !![self firstMatchInString:subject options:0 range:NSMakeRange(0, subject.length)];
}

@end
