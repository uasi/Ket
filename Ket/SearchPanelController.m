#import "SearchPanelController.h"

@interface SearchPanelController ()

@property (nonatomic) IBOutlet NSTextField *queryTextField;

@end

@implementation SearchPanelController

- (void)searchWithQuery:(NSString *)query
{
  NSLog(@"query = %@", query);
  [self.window orderOut:self];
  self.queryTextField.stringValue = @"";
}

#pragma mark Actions

- (IBAction)performSearch:(id)sender
{
  [self searchWithQuery:self.queryTextField.stringValue];
}

@end
