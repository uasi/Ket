#import "DocumentWindow.h"

#import "DocumentController.h"

@implementation DocumentWindow

- (void)keyDown:(NSEvent *)event
{
  BOOL isSlash = [event.charactersIgnoringModifiers isEqualToString:@"/"];
  BOOL isAt = [event.charactersIgnoringModifiers isEqualToString:@"@"];
  BOOL noModKeyPressed = (event.modifierFlags & NSDeviceIndependentModifierFlagsMask) == 0;
  if (isSlash && noModKeyPressed) {
    [[DocumentController sharedDocumentController] showSearchPanelForGenericSearch:self];
  }
  else if (isAt && noModKeyPressed) {
    [[DocumentController sharedDocumentController] showSearchPanelForAddressSearch:self];
  }
  else {
    [super keyDown:event];
  }
}

@end
