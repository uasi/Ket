#import "SearchPanelController.h"

#import "CircleDataProvider.h"
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
  [self.queryTextField selectText:self];
  NSLog(@"query = %@, document = %@", query, document);
  [document.circleDataProvider filterUsingString:query];
}

#pragma mark Actions

- (IBAction)performSearch:(id)sender
{
  [self searchWithQuery:self.queryTextField.stringValue];
}

@end
