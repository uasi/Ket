#import "SearchPanelController.h"

#import "CircleDataProvider.h"
#import "CatalogFilter.h"
#import "Document.h"

@interface SearchPanelController ()

@property (nonatomic) IBOutlet NSTextField *queryTextField;

@end

@implementation SearchPanelController

- (void)searchWithQuery:(NSString *)query
{
  // FIXME: document will be nil if a non-document window,
  // such as Welcome to Ket, is the main window.
  // We need to find a robust way to determine which document is frontmost.
  Document *document = [[NSDocumentController sharedDocumentController] currentDocument];
  [self.window orderOut:self];
  NSLog(@"query = %@, document = %@", query, document);
  [document.circleDataProvider filterWithString:query];
}

#pragma mark Actions

- (IBAction)showWindowForGenericSearch:(id)sender
{
  [self.queryTextField selectText:self];
  [self showWindow:sender];
}

- (IBAction)showWindowForAddressSearch:(id)sender
{
  [self showWindowForSpecialSearch:sender withPrefix:@"@"];
}

- (IBAction)showWindowForLabelSearch:(id)sender
{
  [self showWindowForSpecialSearch:sender withPrefix:@":"];
}

- (void)showWindowForSpecialSearch:(id)sender withPrefix:(NSString *)prefix
{
  // We need to show window prior to creating a field editor,
  // otherwise the field editor will not bound to the text field.
  // No idea why.
  if (![self.window fieldEditor:NO forObject:self.queryTextField]) {
    [self showWindow:self];
  }

  NSString *query = self.queryTextField.stringValue;
  NSText *fieldEditor = [self.window fieldEditor:YES forObject:self.queryTextField];
  if ([query hasPrefix:prefix] && query.length > prefix.length) {
    fieldEditor.selectedRange = NSMakeRange(prefix.length, query.length - prefix.length);
  }
  else {
    fieldEditor.string = prefix;
    fieldEditor.selectedRange = NSMakeRange(fieldEditor.string.length, 0);
  }

  [self showWindow:sender];
}

- (IBAction)performSearch:(id)sender
{
  [self searchWithQuery:self.queryTextField.stringValue];
}

@end
