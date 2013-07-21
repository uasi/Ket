#import "CircleInspectorController.h"

#import "Document.h"
#import "DocumentController.h"

@interface CircleInspectorController ()

@property (nonatomic, readwrite) Circle *circle; // bound to self.docment.selectedCircle.

@property (nonatomic) RACDisposable *circleBindingDisposable;

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

  [RACAble([NSApplication sharedApplication], mainWindow) subscribeNext:^(NSWindow *window) {
    if (self.window.isVisible) {
      self.document = [[DocumentController sharedDocumentController] documentForWindow:window];
    }
  }];

  return self;
}

- (void)setDocument:(Document *)document
{
  [super setDocument:document];

  // Bind self.circle to self.document.selectedCircle.
  if (self.circleBindingDisposable) [self.circleBindingDisposable dispose];
  RACBinding *binding = RACBind(circle);
  self.circleBindingDisposable = [binding bindTo:RACBind(document, selectedCircle)];
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  self.window.delegate = self;
}

#pragma mark - Accessors

- (BOOL)isBookmarked
{
  if (!self.circle) return NO;
  NSNumber *bookmark = self.document.bookmarks[@(self.circle.identifier)];
  return bookmark && bookmark.boolValue;
}

- (void)setBookmarked:(BOOL)isBookmarked {
  if (!self.circle) return;
  self.document.bookmarks[@(self.circle.identifier)] = @(isBookmarked);
}

@end
