#import "CircleCutMatrix.h"

#import "CircleCutCell.h"
#import <ReactiveCocoa/NSNotificationCenter+RACSupport.h>

NSString *const CircleCutMatrixDidSelectCellNotification = @"CircleCutMatrixDidSelectCellNotification";

@interface CircleCutMatrix ()

@end

@implementation CircleCutMatrix

- (instancetype)initWithFrame:(NSRect)frameRect mode:(NSMatrixMode)aMode prototype:(NSCell *)aCell numberOfRows:(NSInteger)rowsHigh numberOfColumns:(NSInteger)colsWide
{
  self = [super initWithFrame:frameRect mode:aMode prototype:aCell numberOfRows:rowsHigh numberOfColumns:colsWide];
  if (!self) return nil;

  // Observe the notification to unhighlight all cells when any other matrix
  // belonging to the same table view highlights a cell.
  @weakify(self);
  [[[NSNotificationCenter defaultCenter] rac_addObserverForName:CircleCutMatrixDidSelectCellNotification object:nil] subscribeNext:^(NSNotification *notification) {
    @strongify(self);
    id other = notification.object;
    NSTableView *otherTableView = notification.userInfo[@"tableView"];
    if (self.superview.superview == otherTableView && self != other) {
      [self unhighlightAllCells];
    }
  }];

  return self;
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
  NSDictionary *userInfo =
  @{@"tableView": self.superview.superview,
    @"cell": cell};
  [[NSNotificationCenter defaultCenter] postNotificationName:CircleCutMatrixDidSelectCellNotification object:self userInfo:userInfo];
}

- (void)unhighlightAllCells
{
  for (CircleCutCell *cell in self.cells) {
    [cell setHighlighted:NO];
  }
  self.highlightedCircleCutCell = nil;
}

@end
