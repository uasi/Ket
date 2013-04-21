#import "CircleCutCell.h"
#import "Circle.h"

#define CUT_SHOULDER_RECT_FOR_CUT_OF_210x300 NSMakeRect(7, 7, 49, 49)

@implementation CircleCutCell

- (instancetype)init
{
  return [super init];
}

- (instancetype)initImageCell:(NSImage *)image
{
  return [super initImageCell:image];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
  return [super initWithCoder:decoder];
}

- (instancetype)initTextCell:(NSString *)string
{
  return [super initTextCell:string];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
  [super drawInteriorWithFrame:cellFrame inView:controlView];

  if (self.circle) {
    [self drawCutShoulderRect:[self cutShoulderRectForCutRect:cellFrame]];
  };

  if (self.isHighlighted) {
    [NSGraphicsContext saveGraphicsState];
    NSColor *color = [NSColor greenColor];
    [color setStroke];
    [NSBezierPath setDefaultLineWidth:10];
    [NSBezierPath strokeRect:cellFrame];
    [NSGraphicsContext restoreGraphicsState];
  }
}

- (void)drawCutShoulderRect:(NSRect)rect
{
  NSGraphicsContext *context = [NSGraphicsContext currentContext];
  [context saveGraphicsState];

  [[NSColor yellowColor] drawSwatchInRect:rect];

  NSDictionary *attributes =
  @{NSFontAttributeName: [NSFont systemFontOfSize:24]};
  [self.circle.spaceString drawAtPoint:rect.origin withAttributes:attributes];

  [context restoreGraphicsState];
}

- (NSRect)cutShoulderRectForCutRect:(NSRect)cutRect
{
  NSRect rect = CUT_SHOULDER_RECT_FOR_CUT_OF_210x300;

  CGFloat scale = cutRect.size.width / 210;
  rect.origin.x *= scale;
  rect.origin.y *= scale;
  rect.size.width *= scale;
  rect.size.height *= scale;

  rect.origin.x += cutRect.origin.x;
  rect.origin.y += cutRect.origin.y;

  return rect;
}

@end
