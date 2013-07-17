@interface NSRegularExpression (Extensions)

+ (BOOL)testString:(NSString *)subject withPattern:(NSString *)pattern;

- (BOOL)testString:(NSString *)subject;

@end
