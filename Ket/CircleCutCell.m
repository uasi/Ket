#import "CircleCutCell.h"

#import "Checklist.h"
#import "Circle.h"
#import "CircleCutMatrix.h"

#define CUT_SHOULDER_RECT_FOR_CUT_OF_210x300 NSMakeRect(7, 7, 49, 49)

@implementation CircleCutCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
  [super drawInteriorWithFrame:cellFrame inView:controlView];

  CircleCutMatrix *matrix = (CircleCutMatrix *)controlView;

  if (self.circle && ![self.circle isEqual:[Circle emptyCircle]]) {
    if ([matrix.checklist bookmarksContainsCircle:self.circle]) {
      NSColor *color = [matrix.checklist colorForCircle:self.circle];
      [self drawCutShoulderBackgroundRect:[self cutShoulderRectForCutRect:cellFrame] withColor:color];
    }
    [self drawCutShoulderForegroundRect:[self cutShoulderRectForCutRect:cellFrame]];
  }

  if (self.isHighlighted) {
    [NSGraphicsContext saveGraphicsState];
    NSColor *color = [NSColor greenColor];
    [color setStroke];
    [NSBezierPath setDefaultLineWidth:5];
    [NSBezierPath strokeRect:NSInsetRect(cellFrame, 2.5, 2.5)];
    [NSGraphicsContext restoreGraphicsState];
  }
}

- (void)drawCutShoulderBackgroundRect:(NSRect)rect withColor:(NSColor *)color
{
  NSGraphicsContext *context = [NSGraphicsContext currentContext];
  [context saveGraphicsState];

  if (![color isEqual:[NSColor clearColor]]) {
    [color drawSwatchInRect:rect];
  }

  [context restoreGraphicsState];
}

- (void)drawCutShoulderForegroundRect:(NSRect)rect
{
  NSGraphicsContext *context = [NSGraphicsContext currentContext];
  [context saveGraphicsState];

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
