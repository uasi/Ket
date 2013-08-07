#import "Document.h"

#import "CatalogImportWindowController.h"
#import "CatalogTableViewDelegate.h"
#import "Checklist.h"
#import "Circle.h"
#import "CircleDataProvider.h"
#import "DocumentController.h"
#import "NSRegularExpression+Extensions.h"
#import "PathUtils.h"

@interface Document ()

@property (nonatomic, readwrite) Circle *selectedCircle; // bound to self.tableViewDelegate.selectedCircle.
@property (nonatomic, readwrite) Checklist *checklist;

@property (nonatomic) IBOutlet CatalogTableViewDelegate *tableViewDelegate;

@property (nonatomic) CircleDataProvider *provider;

@end

@implementation Document

- (NSString *)windowNibName
{
  return @"Document";
}

- (void)prepareDocumentWithComiketNo:(NSUInteger)comiketNo
{
  _comiketNo = comiketNo;
  EnsureDirectoryExistsAtURL(CatalogDirectoryURLWithComiketNo(comiketNo));
  self.checklist = [[Checklist alloc] initWithComiketNo:comiketNo];
  self.provider = [[CircleDataProvider alloc] initWithChecklist:self.checklist];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
  [super windowControllerDidLoadNib:aController];
  RACBind(selectedCircle) = RACBind(self.tableViewDelegate, selectedCircle);
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
  return [self.checklist data];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
  Checklist *checklist = [[Checklist alloc] initWithData:data error:outError];
  if (!checklist) return NO;
  [self prepareDocumentWithComiketNo:checklist.comiketNo];
  self.checklist = checklist;
  return YES;
}

#pragma mark Key Down Handling

- (BOOL)handleKeyDown:(NSEvent *)event
{
  NSString *c = event.charactersIgnoringModifiers;
  BOOL noModKeyPressed = (event.modifierFlags & NSDeviceIndependentModifierFlagsMask) == 0;

  if (noModKeyPressed && [c isEqualToString:@"o"]) {
    if (self.selectedCircle.URL) {
      [[NSWorkspace sharedWorkspace] openURL:self.selectedCircle.URL];
    }
  }
  else if (noModKeyPressed && [c isEqualToString:@"/"]) {
    [[DocumentController sharedDocumentController] showSearchPanelForGenericSearch:self];
  }
  else if (noModKeyPressed && [c isEqualToString:@"@"]) {
    [[DocumentController sharedDocumentController] showSearchPanelForAddressSearch:self];
  }
  else if (noModKeyPressed && [c isEqualToString:@":"]) {
    [[DocumentController sharedDocumentController] showSearchPanelForLabelSearch:self];
  }
  else if (noModKeyPressed && [NSRegularExpression testString:c withPattern:@"^[0-9]$"]) {
    NSInteger colorCode;
    [[NSScanner scannerWithString:c] scanInteger:&colorCode];
    [self.checklist setColorCode:colorCode forCircle:self.selectedCircle];
  }
  else {
    return NO;
  }
  return YES;
}

#pragma mark Actions (As A Responder)

- (IBAction)performFindPanelAction:(id)sender
{
  [[DocumentController sharedDocumentController] showSearchPanelForGenericSearch:self];
}

#pragma mark Accessors

- (CircleDataProvider *)circleDataProvider
{
  return _provider;
}

#pragma mark DocumentWindowDelegate Protocol

- (BOOL)window:(NSWindow *)window shouldPropagateKeyDown:(NSEvent *)event
{
  return ![self handleKeyDown:event];
}

@end
