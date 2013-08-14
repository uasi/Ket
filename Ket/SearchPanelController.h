@interface SearchPanelController : NSWindowController

- (IBAction)showWindowForGenericSearch:(id)sender;
- (IBAction)showWindowForAddressSearch:(id)sender;
- (IBAction)showWindowForLabelSearch:(id)sender;
- (IBAction)performSearch:(id)sender;

@end
