#import "Document.h"

#import "CatalogImportWindowController.h"
#import "CatalogTableViewDelegate.h"
#import "DocumentController.h"
#import "PathUtils.h"

@interface Document ()

@property (nonatomic, readwrite) NSMutableDictionary *bookmarks;
@property (nonatomic, readwrite) Circle *selectedCircle; // bound to self.tableViewDelegate.selectedCircle.

@property (nonatomic) IBOutlet CatalogTableViewDelegate *tableViewDelegate;

@end

@implementation Document

- (id)init
{
  self = [super init];
  if (!self) return nil;

  self.bookmarks = [NSMutableDictionary dictionary];

  return self;
}

- (NSString *)windowNibName
{
  return @"Document";
}

- (void)prepareDocumentWithComiketNo:(NSUInteger)comiketNo
{
  _comiketNo = comiketNo;
  EnsureDirectoryExistsAtURL(CatalogDirectoryURLWithComiketNo(comiketNo));
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
  return [NSKeyedArchiver archivedDataWithRootObject:@{
          @"bookmarks": self.bookmarks,
          }];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
  NSDictionary *properties = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  if (!properties && outError) {
    *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:nil];
    return NO;
  }
  self.bookmarks = properties[@"bookmarks"];
  return YES;
}

#pragma mark Actions (As A Responder)

- (IBAction)performFindPanelAction:(id)sender
{
  [[DocumentController sharedDocumentController] showSearchPanel:self];
}

@end
