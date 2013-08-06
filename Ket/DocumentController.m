#import "DocumentController.h"

#import "CatalogImportWindowController.h"
#import "CircleInspectorController.h"
#import "Document.h"
#import "PathUtils.h"
#import "SearchPanelController.h"
#import "WelcomeWindowController.h"

@interface DocumentController ()

@property (nonatomic, readwrite) CatalogImportWindowController *catalogImportWindowController;
@property (nonatomic, readwrite) CircleInspectorController *circleInspectorController;
@property (nonatomic, readwrite) SearchPanelController *searchPanelController;
@property (nonatomic, readwrite) WelcomeWindowController *welcomeWindowController;

@end

@implementation DocumentController

- (instancetype)init
{
  self = [super init];
  if (!self) return nil;

  self.catalogImportWindowController = [[CatalogImportWindowController alloc] initWithWindowNibName:@"CatalogImportWindow"];
  self.circleInspectorController = [[CircleInspectorController alloc] initWithWindowNibName:@"CircleInspector"];
  self.searchPanelController = [[SearchPanelController alloc] initWithWindowNibName:@"SearchPanel"];
  self.welcomeWindowController = [[WelcomeWindowController alloc] initWithWindowNibName:@"WelcomeWindow"];

  [self.circleInspectorController window];
  [self.searchPanelController window];

  return self;
}

- (void)newDocument:(id)sender
{
  [self.welcomeWindowController showWindow:self];
}

- (id)openUntitledDocumentAndDisplay:(BOOL)displayDocument error:(NSError **)outError
{
  NSUInteger comiketNo = [self latestAvailableComiketNo];
  return [self openUntitledDocumentAndDisplay:displayDocument withComiketNo:comiketNo error:outError];
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

- (NSUInteger)latestAvailableComiketNo
{
  NSArray *catalogURLs = CatalogDirectoryURLs();
  if (!catalogURLs || catalogURLs.count == 0) return 0;
  NSURL *latestCatalogURL = catalogURLs[0];
  return ComiketNoFromString(latestCatalogURL.lastPathComponent);
}

#pragma mark Actions

- (IBAction)showCircleInspector:(id)sender
{
  Document *document = [self documentForWindow:[NSApp mainWindow]];
  self.circleInspectorController.document = document;
  [self.circleInspectorController showWindow:self];
  // TODO: make inspector hidable
}

- (IBAction)showSearchPanelForGenericSearch:(id)sender
{
  [self.searchPanelController showWindowForGenericSearch:self];
}

- (IBAction)showSearchPanelForAddressSearch:(id)sender
{
  [self.searchPanelController showWindowForAddressSearch:self];
}

- (IBAction)showSearchPanelForLabelSearch:(id)sender
{
  [self.searchPanelController showWindowForLabelSearch:self];
}

@end
