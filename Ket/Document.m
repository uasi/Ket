#import "Document.h"

#import "CatalogTableViewDelegate.h"
#import "CircleInspectorController.h"

@interface Document ()

@property (nonatomic) IBOutlet CatalogTableViewDelegate *tableViewDelegate;
@property (nonatomic, weak) CircleInspectorController *circleInspectorController;

@property (nonatomic, readwrite) NSMutableDictionary *bookmarks;

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

- (void)makeWindowControllers
{
  [super makeWindowControllers];
  CircleInspectorController *controller = [[CircleInspectorController alloc] initWithWindowNibName:@"CircleInspector"];
  [self addWindowController:controller];
  self.circleInspectorController = controller;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
  [super windowControllerDidLoadNib:aController];
  // Add any code here that needs to be executed once the windowController has loaded the document's window.
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

- (IBAction)showCircleInspector:(id)sender
{
  [self.circleInspectorController showWindow:self];
}

@end
