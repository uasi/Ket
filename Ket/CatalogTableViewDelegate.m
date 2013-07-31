#import "CatalogTableViewDelegate.h"

#import "CatalogDatabase.h"
#import "Circle.h"
#import "CircleCollection.h"
#import "CircleCutArchive.h"
#import "CircleCutCell.h"
#import "CircleCutMatrix.h"
#import "CircleDataProvider.h"
#import "Document.h"
#import "PathUtils.h"

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
    NSString *blockName = [self.provider.catalogDatabase blockNameForID:cell.circle.blockID];
    NSLog(@"Sender=%@, selected circle block name=%@",notification.object ,blockName);
  }];
}

#pragma mark - NSTableViewDelegate

- (NSSize)cellSizeForTableView:(NSTableView *)tableView
{
  return NSMakeSize(210, 300);
  CatalogDatabase *database = self.provider.catalogDatabase;
  NSSize originalSize = database.cutSize;
  CGFloat scale = tableView.bounds.size.width / (originalSize.width * database.numberOfCutsInColumn);
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
  CatalogDatabase *database = self.provider.catalogDatabase;
  CircleCutArchive *archive = self.provider.circleCutArchive;
  NSUInteger page = indexAtIndex(database.pageNoIndexSet, row / 2);

  if (!tableColumn) {
    NSTextField *textField = [tableView makeViewWithIdentifier:@"GroupRowTextField" owner:nil];
    textField.stringValue = [NSString stringWithFormat:@"Page %d", (int)page];
    return textField;
  }

  NSString *identifier = NSStringFromClass([NSMatrix class]);
  CircleCutMatrix *view = [tableView makeViewWithIdentifier:identifier owner:nil];

  NSUInteger rows = database.numberOfCutsInRow;
  NSUInteger columns = database.numberOfCutsInColumn;

  if (!view) {
    CircleCutCell *prototypeCell = [[CircleCutCell alloc] init];
    prototypeCell.cutSize = archive.cutSize;
    prototypeCell.imageScaling = NSImageScaleProportionallyUpOrDown;
    view = [[CircleCutMatrix alloc] initWithFrame:NSZeroRect mode:NSTrackModeMatrix prototype:prototypeCell numberOfRows:rows numberOfColumns:columns];
    view.identifier = identifier;
    view.intercellSpacing = NSMakeSize(0, 0);
  }

  [view setBoundsSize:NSMakeSize(archive.cutSize.width * columns, archive.cutSize.height * rows)];
  view.cellSize = [self cellSizeForTableView:tableView];
  view.highlightedCircleCutCell = nil;

  NSArray *circles = [database circleCollectionForPage:page].circlesPaddedWithNull;

  for (NSInteger i = 0; i < rows * columns; i++) {
    CircleCutCell *cell = view.cells[i];
    Circle *circle = circles[i];
    if ((NSNull *)circle == [NSNull null]) {
      cell.image = [NSImage imageNamed:@"Placeholder210x300"];
      cell.circle = nil;
    }
    else {
      if (circle == self.selectedCircle) view.highlightedCircleCutCell = cell;
      cell.image = [archive imageForCircle:circle];
      cell.circle = circle;
    }
  }

  return view;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
  if ([self.provider isGroupRow:row]) return 22;
  CatalogDatabase *database = self.provider.catalogDatabase;
  CGFloat scale = tableView.bounds.size.width / (database.cutSize.width * database.numberOfCutsInColumn);
  return (database.cutSize.height * database.numberOfCutsInRow) * scale;
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
  return [self.provider numberOfRows];
}

@end
