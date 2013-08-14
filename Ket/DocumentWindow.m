#import "DocumentWindow.h"

#import "DocumentWindowDelegate.h"

@implementation DocumentWindow

- (void)keyDown:(NSEvent *)event
{
  if (self.delegate && [self.delegate conformsToProtocol:@protocol(DocumentWindowDelegate)]) {
    if (![(id<DocumentWindowDelegate>)self.delegate window:self shouldPropagateKeyDown:event]) {
      return;
    }
  }
  [super keyDown:event];
}

@end
