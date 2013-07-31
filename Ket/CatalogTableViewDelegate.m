#import "CatalogTableViewDelegate.h"

#import "Circle.h"
#import "CircleCollection.h"
#import "CircleCutCell.h"
#import "CircleCutMatrix.h"
#import "CircleDataProvider.h"
#import "Document.h"
#import "PathUtils.h"

static const NSUInteger kHightOfGroupRow = 22;
static const NSTimeInterval kThrottleForReloadingDataOnResizing = 0.1;

@interface CatalogTableViewDelegate ()

@property (nonatomic, weak) IBOutlet Document *document;

@property (nonatomic, readwrite) Circle *selectedCircle;

@property (nonatomic) CircleDataProvider *provider;
@property (nonatomic) RACSubject *tableViewColumnDidResizeSignal;

@end

@implementation CatalogTableViewDelegate

- (void)awakeFromNib
{
  self.provider = [[CircleDataProvider alloc] initWithComiketNo:self.document.comiketNo];

  self.tableViewColumnDidResizeSignal = [RACSubject subject];
  [[self.tableViewColumnDidResizeSignal throttle:kThrottleForReloadingDataOnResizing] subscribeNext:^(NSTableView *tableView) {
    [tableView reloadData];
  }];

  [[[NSNotificationCenter defaultCenter] rac_addObserverForName:CircleCutMatrixDidSelectCellNotification object:nil] subscribeNext:^(NSNotification *notification) {
    CircleCutCell *cell = notification.userInfo[@"cell"];
    self.selectedCircle = cell.circle;
    NSString *blockName = [self.provider blockNameForID:cell.circle.blockID];
    NSLog(@"Sender=%@, selected circle block name=%@",notification.object ,blockName);
  }];
}

#pragma mark - NSTableViewDelegate

- (NSSize)cellSizeForTableView:(NSTableView *)tableView
{
  return NSMakeSize(210, 300);
  NSSize originalSize = self.provider.cutSize;
  CGFloat scale = tableView.bounds.size.width / (originalSize.width * self.provider.numberOfCutsInColumn);
  CGFloat actualWidth = floor(originalSize.width * scale);
  CGFloat actualHeight = floor(originalSize.height * scale);
  return NSMakeSize(actualWidth, actualHeight);
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  if (!tableColumn) {
    NSTextField *textField = [tableView makeViewWithIdentifier:@"GroupRowTextField" owner:nil];
    textField.stringValue = [self.provider stringValueForGroupRow:row];
    return textField;
  }

  NSString *identifier = NSStringFromClass([NSMatrix class]);
  CircleCutMatrix *view = [tableView makeViewWithIdentifier:identifier owner:nil];

  NSUInteger rows = self.provider.numberOfCutsInRow;
  NSUInteger columns = self.provider.numberOfCutsInColumn;

  if (!view) {
    CircleCutCell *prototypeCell = [[CircleCutCell alloc] init];
    prototypeCell.cutSize = self.provider.cutSize;
    prototypeCell.imageScaling = NSImageScaleProportionallyUpOrDown;
    view = [[CircleCutMatrix alloc] initWithFrame:NSZeroRect mode:NSTrackModeMatrix prototype:prototypeCell numberOfRows:rows numberOfColumns:columns];
    view.identifier = identifier;
    view.intercellSpacing = NSMakeSize(0, 0);
  }

  [view setBoundsSize:NSMakeSize(self.provider.cutSize.width * columns, self.provider.cutSize.height * rows)];
  view.cellSize = [self cellSizeForTableView:tableView];
  view.highlightedCircleCutCell = nil;

  NSArray *circles = [self.provider circleCollectionForRow:row].circlesPaddedWithNull;

  for (NSInteger i = 0; i < rows * columns; i++) {
    CircleCutCell *cell = view.cells[i];
    Circle *circle = circles[i];
    if ((NSNull *)circle == [NSNull null]) {
      cell.image = [NSImage imageNamed:@"Placeholder210x300"];
      cell.circle = nil;
    }
    else {
      if (circle == self.selectedCircle) view.highlightedCircleCutCell = cell;
      cell.image = [self.provider imageForCircle:circle];
      cell.circle = circle;
    }
  }

  return view;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
  if ([self.provider isGroupRow:row]) return kHightOfGroupRow;
  NSSize cutSize = self.provider.cutSize;
  CGFloat scale = tableView.bounds.size.width / (cutSize.width * self.provider.numberOfCutsInColumn);
  return (cutSize.height * self.provider.numberOfCutsInRow) * scale;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
  return NO;
}

- (void)tableViewColumnDidResize:(NSNotification *)notification
{
  NSTableView *tableView = notification.object;
  [self.tableViewColumnDidResizeSignal sendNext:tableView];
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
  return [self.provider isGroupRow:row];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return self.provider.numberOfRows;
}

@end
