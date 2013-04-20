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

  NSGraphicsContext *context = [NSGraphicsContext currentContext];
  [context saveGraphicsState];

  NSRect cutShoulderRect = [self cutShoulderRectForCutRect:cellFrame];
  [[NSColor blueColor] drawSwatchInRect:cutShoulderRect];

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
