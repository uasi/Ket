#import "DocumentController.h"

#import "CatalogImportWindowController.h"
#import "WelcomeWindowController.h"

@interface DocumentController ()

@property (nonatomic, readwrite) CatalogImportWindowController *catalogImportWindowController;
@property (nonatomic, readwrite) WelcomeWindowController *welcomeWindowController;

@end

@implementation DocumentController

- (instancetype)init
{
  self = [super init];
  if (!self) return nil;

  self.catalogImportWindowController = [[CatalogImportWindowController alloc] initWithWindowNibName:@"CatalogImportWindow"];
  self.welcomeWindowController = [[WelcomeWindowController alloc] initWithWindowNibName:@"WelcomeWindow"];

  return self;
}

// XXX: Temporary
- (void)newDocument:(id)sender
{
  [self.welcomeWindowController showWindow:self];
}

@end
