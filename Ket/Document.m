#import "Document.h"

#import "CatalogImportWindowController.h"
#import "CatalogTableViewDelegate.h"
#import "Checklist.h"
#import "CircleDataProvider.h"
#import "DocumentController.h"
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
  self.provider = [[CircleDataProvider alloc] initWithComiketNo:comiketNo];
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
  self.checklist = [[Checklist alloc] initWithData:data error:outError];
  return !!self.checklist;
}

#pragma mark Actions (As A Responder)

- (IBAction)performFindPanelAction:(id)sender
{
  [[DocumentController sharedDocumentController] showSearchPanel:self];
}

#pragma mark Accessors

- (CircleDataProvider *)circleDataProvider
{
  return _provider;
}

@end
