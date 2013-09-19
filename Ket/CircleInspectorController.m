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

+ (NSSet *)keyPathsForValuesAffectingNote
{
  return [NSSet setWithObject:@"circle"];
}

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (!self) return nil;

  // Bind self.document to NSApplication.sharedApplication.mainWindow.
  [RACObserve([NSApplication sharedApplication], mainWindow) subscribeNext:^(NSWindow *window) {
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
  self.circle = document.selectedCircle;
  RACChannelTerminal *terminal = RACChannelTo(self, circle);
  self.circleBindingDisposable = [terminal subscribe:RACChannelTo(document, selectedCircle)];

  // Bind self.checklist to self.document.checklist.
  if (self.checklistBindingDisposable) [self.checklistBindingDisposable dispose];
  self.checklist = document.checklist;
  terminal = RACChannelTo(self, checklist);
  self.checklistBindingDisposable = [terminal subscribe:RACChannelTo(document, checklist)];
}

- (NSString *)note
{
  if (!self.circle) return nil;
  return [self.checklist noteForCircle:self.circle];
}

- (void)setNote:(NSString *)string
{
  if (!self.circle) return;
  [self willChangeValueForKey:@"note"];
  [self.checklist setNote:string forCircle:self.circle];
  [self didChangeValueForKey:@"note"];
}

@end
