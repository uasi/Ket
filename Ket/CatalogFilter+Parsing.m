#import "CatalogFilter+Parsing.h"

#import "NSRegularExpression+Extensions.h"

NSString *CatalogFilterJoinStringWithType(CatalogFilterJoinType joinType)
{
  switch (joinType) {
    case CatalogFilterJoinTypeInner: return @"INNER";
    case CatalogFilterJoinTypeLeftOuter: return @"LEFT OUTER";
  }
}

static NSString *escapeSQLMeta(NSString *string);
static NSDictionary *blockNameToIDTable(void);

@implementation CatalogFilter (Parsing)

+ (NSArray *)arrayOfFilterPropertiesByParsingString:(NSString *)string
{
  NSPredicate *nonempty = [NSPredicate predicateWithFormat:@"self != ''"];
  NSArray *components = [[string componentsSeparatedByString:@" "] filteredArrayUsingPredicate:nonempty];
  NSMutableArray *result = [NSMutableArray array];
  NSDictionary *properties;
  for (NSString *component in components) {
    if ([component hasPrefix:@"@"]) {
      properties = [self propertiesByParsingCompactAddress:component];
      if (properties) [result addObject:properties];
    }
    else if ([component hasPrefix:@":"]) {
      properties = [self propertiesByParsingLabel:component];
      if (properties) [result addObject:properties];
    }
    else {
      properties = [self propertiesOfOrdinaryWord:component];
      if (properties) [result addObject:properties];
    }
  }
  return [result copy];
}

+ (NSDictionary *)propertiesByParsingLabel:(NSString *)label
{
  NSString *constraint;
  CatalogFilterJoinType joinType;
  if ([@":bookmarked" hasPrefix:label]) {
    constraint = @"(bookmarked)";
    joinType = CatalogFilterJoinTypeInner;
  }
  else if ([@":!bookmarked" hasPrefix:label]) {
    constraint = @"(bookmarked ISNULL)";
    joinType = CatalogFilterJoinTypeLeftOuter;
  }
  else {
    return @{@"constraint": @"0"};
  }
  return @{@"constraint": constraint,
           @"requiresChecklist": @YES,
           @"joinType": @(joinType)};
}

+ (NSDictionary *)propertiesOfOrdinaryWord:(NSString *)word
{
  NSString *constraint = [NSString stringWithFormat:
                          @"(description LIKE '%%%@%%')",
                          escapeSQLMeta(word)];
  return @{@"constraint": constraint};
}

+ (NSDictionary *)propertiesByParsingCompactAddress:(NSString *)compactAddress
{
  NSDictionary *components = [self componentsByScanningCompactAddress:compactAddress];
  if (!components) return @{@"constraint": @"0"};
  return @{@"constraint": [self constraintWithCompactAddressComponents:components]};
}

#define SET_SUBSTR_IF_PRESENTS(subscript, string, result, index) \
if ([result rangeAtIndex:index].length > 0) { \
  subscript = [string substringWithRange:[result rangeAtIndex:index]]; \
}

+ (NSDictionary *)componentsByScanningCompactAddress:(NSString *)compactAddress
{
  static NSRegularExpression *regex;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSString *pattern = (@"^@([1-3])" // 1: day
                         @"(?:[EW]?" // east or west
                         @"(?:([A-Z]|(?:[kstnhfpmyr]|sh|ch|ts)?[aiueo][hk]?)" // 2: block
                         @"(?:(\\d{1,2})" // 3: space
                         @"(?:([ab]?)" // 4: subspace
                         @")?)?)?)?");
    NSError *error;
    regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSCAssert(regex, @"%@", error);
  });

  NSTextCheckingResult *result = [regex firstMatchInString:compactAddress options:0 range:NSMakeRange(0, compactAddress.length)];
  if (!result) return nil;

  NSMutableDictionary *components = [NSMutableDictionary dictionary];
  SET_SUBSTR_IF_PRESENTS(components[@"day"], compactAddress, result, 1);
  SET_SUBSTR_IF_PRESENTS(components[@"block"], compactAddress, result, 2);
  SET_SUBSTR_IF_PRESENTS(components[@"space"], compactAddress, result, 3);
  SET_SUBSTR_IF_PRESENTS(components[@"subspace"], compactAddress, result, 4);
  return [components copy];
}

+ (NSString *)constraintWithCompactAddressComponents:(NSDictionary *)components
{
  NSMutableArray *constraints = [NSMutableArray array];
  NSString *c;

  if ((c = components[@"day"])) {
    [constraints addObject:[NSString stringWithFormat:@"day = %@", c]];
  }

  if ((c = components[@"block"])) {
    NSArray *blockIDs;
    if ([NSRegularExpression testString:c withPattern:@"^[A-Z]$|[kh]$"]) {
      blockIDs = @[blockNameToIDTable()[c] ?: @0];
    }
    else {
      blockIDs = @[blockNameToIDTable()[[c stringByAppendingString:@"k"]] ?: @0,
                   blockNameToIDTable()[[c stringByAppendingString:@"h"]] ?: @0];
    }
    NSString *blockIDList = [blockIDs componentsJoinedByString:@", "];
    [constraints addObject:[NSString stringWithFormat:@"blockId IN (%@)", blockIDList]];
  }

  if ((c = components[@"space"])) {
    [constraints addObject:[NSString stringWithFormat:@"spaceNo = %@", c]];
  }

  if ((c = components[@"subspace"])) {
    NSInteger spaceNoSub;
    if ([c isEqualToString:@"a"]) spaceNoSub = 0;
    else if ([c isEqualToString:@"b"]) spaceNoSub = 1;
    else spaceNoSub = -1;
    [constraints addObject:[NSString stringWithFormat:@"spaceNoSub = %ld", (long)spaceNoSub]];
  }

  return [NSString stringWithFormat:@"(%@)", [constraints componentsJoinedByString:@" AND "]];
}

@end

#pragma mark -

static NSString *escapeSQLMeta(NSString *string)
{
  string = [string stringByReplacingOccurrencesOfString:@"$" withString:@"$$"];
  string = [string stringByReplacingOccurrencesOfString:@"%" withString:@"$%"];
  string = [string stringByReplacingOccurrencesOfString:@"_" withString:@"$_"];
  string = [string stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
  return string;
}

static NSDictionary *blockNameToIDTable(void)
{
  static NSDictionary *table;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSMutableDictionary *t = [NSMutableDictionary dictionary];
    // Map A..Z to 1..26.
    NSInteger i= 1;
    for (unsigned char c = 'A'; c <= 'Z'; c++) {
      t[[NSString stringWithFormat:@"%c", c]] = @(i++);
    }
    // Map Katakana.
    t[@"ak"] = @(i++);
    t[@"ik"] = @(i++);
    t[@"uk"] = @(i++);
    t[@"ek"] = @(i++);
    t[@"ok"] = @(i++);
    t[@"kak"] = @(i++);
    t[@"kik"] = @(i++);
    t[@"kuk"] = @(i++);
    t[@"kek"] = @(i++);
    t[@"kok"] = @(i++);
    t[@"sak"] = @(i++);
    t[@"sik"] = @(i++);
    t[@"shik"] = @(i); // alias to sik
    t[@"suk"] = @(i++);
    t[@"sek"] = @(i++);
    t[@"sok"] = @(i++);
    t[@"tak"] = @(i++);
    t[@"tik"] = @(i++);
    t[@"chik"] = @(i); // alias to tik
    t[@"tuk"] = @(i++);
    t[@"tsuk"] = @(i++); // alias to tuk
    t[@"tek"] = @(i++);
    t[@"tok"] = @(i++);
    t[@"nak"] = @(i++);
    t[@"nik"] = @(i++);
    t[@"nuk"] = @(i++);
    t[@"nek"] = @(i++);
    t[@"nok"] = @(i++);
    t[@"hak"] = @(i++);
    t[@"pak"] = @(i++);
    t[@"hik"] = @(i++);
    t[@"pik"] = @(i++);
    t[@"huk"] = @(i++);
    t[@"fuk"] = @(i); // alias to huk
    t[@"puk"] = @(i++);
    t[@"hek"] = @(i++);
    t[@"pek"] = @(i++);
    t[@"hok"] = @(i++);
    t[@"pok"] = @(i++);
    t[@"mak"] = @(i++);
    t[@"mik"] = @(i++);
    t[@"muk"] = @(i++);
    t[@"mek"] = @(i++);
    t[@"mok"] = @(i++);
    t[@"yak"] = @(i++);
    t[@"yuk"] = @(i++);
    t[@"yok"] = @(i++);
    t[@"rak"] = @(i++);
    t[@"rik"] = @(i++);
    t[@"ruk"] = @(i++);
    t[@"rek"] = @(i++);
    t[@"rok"] = @(i++);
    // Map hiragana.
    t[@"ah"] = @(i++);
    t[@"ih"] = @(i++);
    t[@"uh"] = @(i++);
    t[@"eh"] = @(i++);
    t[@"oh"] = @(i++);
    t[@"kah"] = @(i++);
    t[@"kih"] = @(i++);
    t[@"kuh"] = @(i++);
    t[@"keh"] = @(i++);
    t[@"koh"] = @(i++);
    t[@"sah"] = @(i++);
    t[@"sih"] = @(i++);
    t[@"shih"] = @(i); // alias to sih
    t[@"suh"] = @(i++);
    t[@"seh"] = @(i++);
    t[@"soh"] = @(i++);
    t[@"tah"] = @(i++);
    t[@"tih"] = @(i++);
    t[@"chih"] = @(i); // alias to tih
    t[@"tuh"] = @(i++);
    t[@"tsuh"] = @(i); // alias to tuh
    t[@"teh"] = @(i++);
    t[@"toh"] = @(i++);
    t[@"nah"] = @(i++);
    t[@"nih"] = @(i++);
    t[@"nuh"] = @(i++);
    t[@"neh"] = @(i++);
    t[@"noh"] = @(i++);
    t[@"hah"] = @(i++);
    t[@"hih"] = @(i++);
    t[@"huh"] = @(i++);
    t[@"fuh"] = @(i); // alias to huh
    t[@"heh"] = @(i++);
    t[@"hoh"] = @(i++);
    t[@"mah"] = @(i++);
    t[@"mih"] = @(i++);
    t[@"muh"] = @(i++);
    t[@"meh"] = @(i++);
    t[@"moh"] = @(i++);
    t[@"yah"] = @(i++);
    t[@"yuh"] = @(i++);
    t[@"yoh"] = @(i++);
    t[@"rah"] = @(i++);
    t[@"rih"] = @(i++);
    t[@"ruh"] = @(i++);
    t[@"reh"] = @(i++);
    t[@"roh"] = @(i++); // unused
    table = [t copy];
  });
  return table;
}
