#import "CatalogTableViewDelegate.h"
#import "CatalogTableCellView.h"

@implementation CatalogTableViewDelegate

#pragma mark -
#pragma mark NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSString *identifier = NSStringFromClass([CatalogTableCellView class]);
  CatalogTableCellView *view = [tableView makeViewWithIdentifier:identifier owner:self];

  if (!view) {
    view = [[CatalogTableCellView alloc] init];
    view.identifier = identifier;
  }

  return view;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
  return 300;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
  return NO;
}

- (void)tableViewColumnDidResize:(NSNotification *)notification
{
  NSTableView *tableView = notification.object;
  //[tableView reloadData];
  [tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tableView.numberOfRows)]];
}

@end
