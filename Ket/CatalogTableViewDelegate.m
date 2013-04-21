#import "CatalogTableViewDelegate.h"
#import "CatalogTableCellView.h"
#import "CatalogDatabase.h"
#import "CircleCutArchive.h"
#import "CircleCutCell.h"
#import "Circle.h"
#import <ReactiveCocoa/NSNotificationCenter+RACSupport.h>

#define RELOAD_DATA_ON_RESIZING_THROTTOLE 0.1

@interface CatalogTableViewDelegate ()

@property (strong, nonatomic) CatalogDatabase *database;
@property (strong, nonatomic) CircleCutArchive *archive;
@property (strong, nonatomic) RACSubject *tableViewColumnDidResizeSignal;

@end

@implementation CatalogTableViewDelegate

- (void)awakeFromNib
{
  self.database = [CatalogDatabase databaseWithContentsOfFile:@"/Users/uasi/tmp/CCATALOG79.sqlite3"];
  self.archive = [CircleCutArchive archiveWithContentsOfURL:[NSURL URLWithString:@"file://localhost/Users/uasi/tmp/C079CUTH.CCZ"]];

  self.tableViewColumnDidResizeSignal = [RACSubject subject];
  [[self.tableViewColumnDidResizeSignal throttle:RELOAD_DATA_ON_RESIZING_THROTTOLE] subscribeNext:^(NSTableView *tableView) {
    [tableView reloadData];
  }];
}

#pragma mark -
#pragma mark NSTableViewDelegate

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
  if (!tableColumn) {
    NSTextField *textField = [tableView makeViewWithIdentifier:@"GroupRowTextField" owner:self];
    textField.stringValue = @"Group Row";
    return textField;
  }

  row /= 2;

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

  [view setBoundsSize:NSMakeSize(210*6, 300*6)];
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

#pragma mark -
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return self.database.pageNoIndexSet.count * 2;
}

@end
