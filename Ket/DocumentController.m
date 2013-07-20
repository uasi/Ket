#import "DocumentController.h"

#import "CatalogImportWindowController.h"
#import "Document.h"
#import "SearchPanelController.h"
#import "WelcomeWindowController.h"

@interface DocumentController ()

@property (nonatomic, readwrite) CatalogImportWindowController *catalogImportWindowController;
@property (nonatomic, readwrite) SearchPanelController *searchPanelController;
@property (nonatomic, readwrite) WelcomeWindowController *welcomeWindowController;

@end

@implementation DocumentController

- (instancetype)init
{
  self = [super init];
  if (!self) return nil;

  self.catalogImportWindowController = [[CatalogImportWindowController alloc] initWithWindowNibName:@"CatalogImportWindow"];
  self.searchPanelController = [[SearchPanelController alloc] initWithWindowNibName:@"SearchPanel"];
  self.welcomeWindowController = [[WelcomeWindowController alloc] initWithWindowNibName:@"WelcomeWindow"];

  return self;
}

- (void)newDocument:(id)sender
{
  [self.welcomeWindowController showWindow:self];
}

- (id)openUntitledDocumentAndDisplay:(BOOL)displayDocument error:(NSError **)outError
{
  return [self openUntitledDocumentAndDisplay:displayDocument withComiketNo:79 error:outError];
}

- (id)openUntitledDocumentAndDisplay:(BOOL)displayDocument withComiketNo:(NSUInteger)comiketNo error:(NSError **)outError
{
  Document *document = [super openUntitledDocumentAndDisplay:NO error:outError];
  if (!document) return nil;
  [document prepareDocumentWithComiketNo:comiketNo];
  if (displayDocument) {
    [document makeWindowControllers];
    [document showWindows];
  }
  return document;
}

- (void)openSearchPanel
{
  [self.searchPanelController showWindow:self];
}

@end
