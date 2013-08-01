#import "CircleCollection.h"

#import "Circle.h"

@interface CircleCollection ()

@property (nonatomic, copy, readwrite) NSArray *circles;
@property (nonatomic, copy, readwrite) NSArray *circlesPaddedWithEmptyCircle;

@end

@implementation CircleCollection

@synthesize summary = _summary;

- (instancetype)initWithCircles:(NSArray *)circles count:(NSUInteger)count respectsCutIndex:(BOOL)respectsCutIndex
{
  self = [super init];
  if (!self) return nil;

  self.circles = circles;

  NSMutableArray *paddedCircles = [NSMutableArray arrayWithCapacity:count];

  if (respectsCutIndex) {
    NSInteger circleIndex = 0;
    for (NSInteger cutIndex = 1; cutIndex <= count; cutIndex++) {
      if (circleIndex >= self.circles.count || cutIndex != ((Circle *)self.circles[circleIndex]).cutIndex) {
        paddedCircles[cutIndex - 1] = [Circle emptyCircle];
      }
      else {
        paddedCircles[cutIndex - 1] = circles[circleIndex++];
      }
    }
  }
  else {
    [paddedCircles addObjectsFromArray:circles];
    NSInteger paddings = count - circles.count;
    for (NSInteger i = 0; i < paddings; i++) {
      [paddedCircles addObject:[Circle emptyCircle]];
    }
  }

  self.circlesPaddedWithEmptyCircle = paddedCircles;

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

  if (self.circles.count == 0) {
    _summary = @"(Empty)";
    return _summary;
  }

  NSArray *circles = [self.circles sortedArrayUsingSelector:@selector(compare:)];
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
