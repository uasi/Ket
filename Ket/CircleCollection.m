#import "CircleCollection.h"

#import "Circle.h"

@interface CircleCollection ()

@property (nonatomic, copy, readwrite) NSArray *circles;
@property (nonatomic, copy, readwrite) NSArray *circlesPaddedWithEmptyCircle;

@end

@implementation CircleCollection

- (instancetype)initWithCircles:(NSArray *)circles
                cutCountPerPage:(NSUInteger)count
               respectsCutIndex:(BOOL)respectsCutIndex
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

@dynamic page;

- (NSUInteger)page
{
  return ((Circle *)self.circles[0]).page;
}

@end
