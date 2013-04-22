#import "CircleCollection.h"
#import "Circle.h"

@interface CircleCollection ()

@property (readwrite, copy, nonatomic) NSArray *circles;
@property (readwrite, copy, nonatomic) NSArray *circlesPaddedWithNull;

@end

@implementation CircleCollection

- (instancetype)initWithCircles:(NSArray *)circles
                cutCountPerPage:(NSUInteger)count
{
  self = [super init];
  if (!self) return nil;

  self.circles = circles;

  NSMutableArray *paddedCircles = [NSMutableArray arrayWithCapacity:count];

  NSInteger circleIndex = 0;
  for (NSInteger cutIndex = 1; cutIndex <= count; cutIndex++) {
    if (circleIndex >= self.circles.count || cutIndex != ((Circle *)self.circles[circleIndex]).cutIndex) {
      paddedCircles[cutIndex - 1] = [NSNull null];
    }
    else {
      paddedCircles[cutIndex - 1] = circles[circleIndex++];
    }
  }
  self.circlesPaddedWithNull = paddedCircles;

  return self;
}

@dynamic page;

- (NSUInteger)page
{
  return ((Circle *)self.circles[0]).page;
}

@end
