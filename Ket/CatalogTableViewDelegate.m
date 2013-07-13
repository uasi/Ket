#import "CatalogTableViewDelegate.h"

#import "CatalogDatabase.h"
#import "Circle.h"
#import "CircleCollection.h"
#import "CircleCutArchive.h"
#import "CircleCutCell.h"
#import "CircleCutMatrix.h"
#import "PathUtils.h"

static const NSTimeInterval ThrottleForReloadingDataOnResizing = 0.1;

@interface CatalogTableViewDelegate ()

@property (nonatomic, readwrite) Circle *selectedCircle;

@property (nonatomic) CatalogDatabase *database;
@property (nonatomic) CircleCutArchive *archive;
@property (nonatomic) RACSubject *tableViewColumnDidResizeSignal;

@end

@implementation CatalogTableViewDelegate

- (void)awakeFromNib
{
  self.database = [CatalogDatabase databaseWithContentsOfURL:CatalogDatabaseURLWithComiketID(@"C079")];
  self.archive = [CircleCutArchive archiveWithContentsOfURL:CircleCutArchiveURLWithComiketID(@"C079")];

  self.tableViewColumnDidResizeSignal = [RACSubject subject];
  [[self.tableViewColumnDidResizeSignal throttle:ThrottleForReloadingDataOnResizing] subscribeNext:^(NSTableView *tableView) {
    [tableView reloadData];
  }];

  [[[NSNotificationCenter defaultCenter] rac_addObserverForName:CircleCutMatrixDidSelectCellNotification object:nil] subscribeNext:^(NSNotification *notification) {
    CircleCutCell *cell = notification.userInfo[@"cell"];
    self.selectedCircle = cell.circle;
    NSString *blockName = [self.database blockNameForID:cell.circle.blockID];
    NSLog(@"Sender=%@, selected circle block name=%@",notification.object ,blockName);
  }];
}

#pragma mark - NSTableViewDelegate

- (NSSize)cellSizeForTableView:(NSTableView *)tableView
{
  return NSMakeSize(210, 300);
  NSSize originalSize = self.database.cutSize;
  CGFloat scale = tableView.bounds.size.width / (originalSize.width * self.database.numberOfCutsInColumn);
  CGFloat actualWidth = floor(originalSize.width * scale);
  CGFloat actualHeight = floor(originalSize.height * scale);
  return NSMakeSize(actualWidth, actualHeight);
}

static NSUInteger indexAtIndex(NSIndexSet *indexSet, NSUInteger index)
{
  __block NSUInteger resultIndex = 0;
  __block NSUInteger i = index;

  [indexSet enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
    if (i > range.length) {
      i -= range.length + 1;
    }
    else {
      resultIndex = range.location + i;
      *stop = YES;
    }
  }];

  return resultIndex;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSUInteger page = indexAtIndex(self.database.pageNoIndexSet, row / 2);

  if (!tableColumn) {
    NSTextField *textField = [tableView makeViewWithIdentifier:@"GroupRowTextField" owner:nil];
    textField.stringValue = [NSString stringWithFormat:@"Page %d", (int)page];
    return textField;
  }

  NSString *identifier = NSStringFromClass([NSMatrix class]);
  CircleCutMatrix *view = [tableView makeViewWithIdentifier:identifier owner:nil];

  NSUInteger rows = self.database.numberOfCutsInRow;
  NSUInteger columns = self.database.numberOfCutsInColumn;

  if (!view) {
    CircleCutCell *prototypeCell = [[CircleCutCell alloc] init];
    prototypeCell.cutSize = self.archive.cutSize;
    prototypeCell.imageScaling = NSImageScaleProportionallyUpOrDown;
    view = [[CircleCutMatrix alloc] initWithFrame:NSZeroRect mode:NSTrackModeMatrix prototype:prototypeCell numberOfRows:rows numberOfColumns:columns];
    view.identifier = identifier;
    view.intercellSpacing = NSMakeSize(0, 0);
  }

  [view setBoundsSize:NSMakeSize(self.archive.cutSize.width * columns, self.archive.cutSize.height * rows)];
  view.cellSize = [self cellSizeForTableView:tableView];
  view.highlightedCircleCutCell = nil;

  NSArray *circles = [self.database circleCollectionForPage:page].circlesPaddedWithNull;

  for (NSInteger i = 0; i < rows * columns; i++) {
    CircleCutCell *cell = view.cells[i];
    Circle *circle = circles[i];
    if ((NSNull *)circle == [NSNull null]) {
      cell.image = [NSImage imageNamed:@"Placeholder210x300"];
      cell.circle = nil;
    }
    else {
      if (circle == self.selectedCircle) view.highlightedCircleCutCell = cell;
      cell.image = [self.archive imageForCircle:circle];
      cell.circle = circle;
    }
  }

  return view;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
  if (row % 2 == 0) return 22;
  CGFloat scale = tableView.bounds.size.width / (self.database.cutSize.width * self.database.numberOfCutsInColumn);
  return (self.database.cutSize.height * self.database.numberOfCutsInRow) * scale;
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
  return row % 2 == 0;
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return self.database.pageNoIndexSet.count * 2;
}

@end
