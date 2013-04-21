#import "CatalogTableViewDelegate.h"
#import "CatalogTableCellView.h"
#import "CatalogDatabase.h"
#import "CircleCutArchive.h"
#import "CircleCutCell.h"
#import "Circle.h"

@interface CatalogTableViewDelegate ()

@property (strong, nonatomic) CatalogDatabase *database;
@property (strong, nonatomic) CircleCutArchive *archive;

@end

@implementation CatalogTableViewDelegate

- (void)awakeFromNib
{
  self.database = [CatalogDatabase databaseWithContentsOfFile:@"/Users/uasi/tmp/CCATALOG79.sqlite3"];
  self.archive = [CircleCutArchive archiveWithContentsOfURL:[NSURL URLWithString:@"file://localhost/Users/uasi/tmp/C079CUTH.CCZ"]];
}

#pragma mark -
#pragma mark NSTableViewDelegate

- (NSSize)cellSizeForTableView:(NSTableView *)tableView
{
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
  NSString *identifier = NSStringFromClass([NSMatrix class]);
  NSMatrix *view = [tableView makeViewWithIdentifier:identifier owner:self];

  NSUInteger rows = self.database.numberOfCutsInRow;
  NSUInteger columns = self.database.numberOfCutsInColumn;

  if (!view) {
    CircleCutCell *prototypeCell = [[CircleCutCell alloc] init];
    prototypeCell.cutSize = self.archive.cutSize;
    prototypeCell.imageScaling = NSImageScaleProportionallyUpOrDown;
    view = [[NSMatrix alloc] initWithFrame:NSZeroRect mode:NSTrackModeMatrix prototype:prototypeCell numberOfRows:rows numberOfColumns:columns];
    view.identifier = identifier;
    view.intercellSpacing = NSMakeSize(0, 0);
  }

  view.cellSize = [self cellSizeForTableView:tableView];

  NSArray *circles = [self.database circlesInPagePaddedWithNull:indexAtIndex(self.database.pageNoIndexSet, row)];

  for (NSInteger i = 0; i < rows * columns; i++) {
    CircleCutCell *cell = view.cells[i];
    Circle *circle = circles[i];
    if ((NSNull *)circle == [NSNull null]) {
      cell.image = [NSImage imageNamed:@"Placeholder210x300"];
    }
    else {
      cell.image = [self.archive imageForCircle:circle];
      cell.circle = circle;
    }
  }
  
  return view;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
  return [self cellSizeForTableView:tableView].height * self.database.numberOfCutsInRow;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
  return NO;
}

- (void)tableViewColumnDidResize:(NSNotification *)notification
{
  NSTableView *tableView = notification.object;
  NSRange visibleRows = [tableView rowsInRect:tableView.bounds];

  NSSize cellSize = [self cellSizeForTableView:tableView];
  for (NSInteger row = visibleRows.location; row < visibleRows.location + visibleRows.length; row++) {
    NSMatrix *matrix = [tableView viewAtColumn:0 row:row makeIfNecessary:NO];
    if (matrix) matrix.cellSize = cellSize;
  }

  [tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:visibleRows]];
}

#pragma mark -
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return self.database.pageNoIndexSet.count;
}

@end
