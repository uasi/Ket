#import "CircleInspectorController.h"

#import "Document.h"

@interface CircleInspectorController ()

@end

@implementation CircleInspectorController

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (!self) return nil;
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  self.window.delegate = self;
}

- (BOOL)windowShouldClose:(id)sender
{
  [self.window orderOut:sender];
  return NO;
}

@end
