#import "CircleInspectorController.h"

#import "Checklist.h"
#import "Circle.h"
#import "Document.h"
#import "DocumentController.h"

@interface CircleInspectorController ()

@property (nonatomic, readwrite) Circle *circle; // bound to self.docment.selectedCircle.
@property (nonatomic, readwrite) Checklist *checklist; // bound to self.document.checklist.

@property (nonatomic) RACDisposable *circleBindingDisposable;
@property (nonatomic) RACDisposable *checklistBindingDisposable;


@end

@implementation CircleInspectorController

+ (NSSet *)keyPathsForValuesAffectingBookmarked
{
  return [NSSet setWithObject:@"circle"];
}

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (!self) return nil;

  // Bind self.document to NSApplication.sharedApplication.mainWindow.
  [RACAble([NSApplication sharedApplication], mainWindow) subscribeNext:^(NSWindow *window) {
    if (self.window.isVisible) {
      self.document = [[DocumentController sharedDocumentController] documentForWindow:window];
    }
  }];

  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  self.window.delegate = self;
}

#pragma mark Accessors

- (void)setDocument:(Document *)document
{
  [super setDocument:document];

  // Bind self.circle to self.document.selectedCircle.
  if (self.circleBindingDisposable) [self.circleBindingDisposable dispose];
  RACBinding *binding = RACBind(self.circle);
  self.circleBindingDisposable = [binding bindTo:RACBind(document, selectedCircle)];

  // Bind self.checklist to self.document.checklist.
  if (self.checklistBindingDisposable) [self.checklistBindingDisposable dispose];
  binding = RACBind(self.checklist);
  self.checklistBindingDisposable = [binding bindTo:RACBind(document, checklist)];
  
}

- (BOOL)isBookmarked
{
  if (!self.circle) return NO;
  return [self.checklist bookmarksContainsCircle:self.circle];
}

- (void)setBookmarked:(BOOL)bookmarked {
  if (!self.circle) return;
  [self willChangeValueForKey:@"bookmarked"];
  if (bookmarked) {
    [self.checklist addCircleToBookmarks:self.circle];
  }
  else {
    [self.checklist removeCircleFromBookmarks:self.circle];
  }
  [self didChangeValueForKey:@"bookmarked"];
}

@end
