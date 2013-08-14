#import "CircleCollection.h"

#import "Circle.h"

@interface CircleCollection ()

@property (nonatomic, copy, readwrite) NSArray *nonEmptyCircles;
@property (nonatomic, copy, readwrite) NSArray *circles;

@end

@implementation CircleCollection

@synthesize summary = _summary;

+ (CircleCollection *)emptyCircleCollectionWithMaxCount:(NSUInteger)maxCount
{
  return [[CircleCollection alloc] initWithCircles:@[] maxCount:maxCount respectsCutIndex:NO];
}

- (instancetype)initWithCircles:(NSArray *)circles maxCount:(NSUInteger)maxCount respectsCutIndex:(BOOL)respectsCutIndex
{
  self = [super init];
  if (!self) return nil;

  self.nonEmptyCircles = circles;

  NSMutableArray *paddedCircles = [NSMutableArray arrayWithCapacity:maxCount];

  if (respectsCutIndex) {
    NSInteger circleIndex = 0;
    for (NSInteger cutIndex = 1; cutIndex <= maxCount; cutIndex++) {
      if (circleIndex >= circles.count || cutIndex != ((Circle *)circles[circleIndex]).cutIndex) {
        paddedCircles[cutIndex - 1] = [Circle emptyCircle];
      }
      else {
        paddedCircles[cutIndex - 1] = circles[circleIndex++];
      }
    }
  }
  else {
    [paddedCircles addObjectsFromArray:circles];
    NSInteger paddings = maxCount - circles.count;
    for (NSInteger i = 0; i < paddings; i++) {
      [paddedCircles addObject:[Circle emptyCircle]];
    }
  }

  self.circles = paddedCircles;

  return self;
}

static NSString *circleSummary(Circle *circle) {
  return [NSString stringWithFormat:
          @"Page %lu [%lu]",
          (unsigned long)circle.page,
          (unsigned long)circle.cutIndex];
}

- (NSString *)summary {
  if (_summary) return _summary;

  if (self.nonEmptyCircles.count == 0) {
    _summary = @"(Empty)";
    return _summary;
  }

  NSArray *circles = [self.nonEmptyCircles sortedArrayUsingSelector:@selector(compare:)];
  Circle *minCircle = circles[0];
  Circle *maxCircle = circles.lastObject;
  if ([minCircle isEqual:maxCircle]) {
    _summary = circleSummary(minCircle);
  }
  else {
    _summary = [NSString stringWithFormat:
                @"%@ - %@",
                circleSummary(minCircle),
                circleSummary(maxCircle)];
  }
  return _summary;
}

@end
