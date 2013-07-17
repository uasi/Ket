#import "DocumentController.h"

#import "WelcomeWindowController.h"

@interface DocumentController ()

@property (nonatomic) NSMutableSet *wcPool;

@end

@implementation DocumentController

// XXX: Temporary
- (void)newDocument:(id)sender
{
  if (!self.wcPool) self.wcPool = [NSMutableSet set];
  NSWindowController *wc = [[WelcomeWindowController alloc] initWithWindowNibName:@"WelcomeWindow"];
  [self.wcPool addObject:wc];
  [wc showWindow:self];
}

@end
