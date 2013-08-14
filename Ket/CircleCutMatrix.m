#import "CircleCutMatrix.h"

#import "Checklist.h"
#import "CircleCutCell.h"
#import <ReactiveCocoa/NSNotificationCenter+RACSupport.h>

NSString *const CircleCutMatrixDidSelectCellNotification = @"CircleCutMatrixDidSelectCellNotification";

@interface CircleCutMatrix ()

@property (nonatomic, readwrite) Checklist *checklist;

@property (nonatomic) RACDisposable *disposableForDidSelectCell;
@property (nonatomic) RACDisposable *disposableForChecklistDidChange;

@end

@implementation CircleCutMatrix

- (instancetype)initWithFrame:(NSRect)frameRect mode:(NSMatrixMode)aMode prototype:(NSCell *)aCell numberOfRows:(NSInteger)rowsHigh numberOfColumns:(NSInteger)colsWide
{
  self = [super initWithFrame:frameRect mode:aMode prototype:aCell numberOfRows:rowsHigh numberOfColumns:colsWide];
  if (!self) return nil;

  // Observe the notification to unhighlight all cells when any other matrix
  // belonging to the same table view highlights a cell.
  @weakify(self);
  RACDisposable *d = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:CircleCutMatrixDidSelectCellNotification object:nil] subscribeNext:^(NSNotification *notification) {
    @strongify(self);
    CircleCutMatrix *other = notification.object;
    if (self != other && self.superview.superview == other.superview.superview) {
      [self unhighlightAllCells];
    }
  }];
  if (self.disposableForDidSelectCell) [self.disposableForDidSelectCell dispose];
  self.disposableForDidSelectCell = d;

  return self;
}

- (void)dealloc
{
  if (self.disposableForDidSelectCell) [self.disposableForDidSelectCell dispose];
  if (self.disposableForChecklistDidChange) [self.disposableForChecklistDidChange dispose];
}

- (void)prepareMatrixWithChecklist:(Checklist *)checklist
{
  self.checklist = checklist;
  RACDisposable *d = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:ChecklistDidChangeNotification object:checklist] subscribeNext:^(NSNotification *notification) {
    self.needsDisplay = YES;
  }];
  if (self.disposableForChecklistDidChange) [self.disposableForChecklistDidChange dispose];
  self.disposableForChecklistDidChange = d;
}

- (void)mouseDown:(NSEvent *)event
{
  NSPoint mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
  NSInteger row;
  NSInteger column;
  if (![self getRow:&row column:&column forPoint:mouseLocation]) return;

  // Highlight the clicked cell and unhighlight others.
  [self unhighlightAllCells];
  CircleCutCell *cell = [self cellAtRow:row column:column];
  [cell setHighlighted:!cell.isHighlighted];
  self.highlightedCircleCutCell = cell;

  // Post a notification to tell other matrices to unhighlight cells.
  [[NSNotificationCenter defaultCenter] postNotificationName:CircleCutMatrixDidSelectCellNotification object:self userInfo:nil];
}

- (void)unhighlightAllCells
{
  for (CircleCutCell *cell in self.cells) {
    [cell setHighlighted:NO];
  }
  self.highlightedCircleCutCell = nil;
}

@end
