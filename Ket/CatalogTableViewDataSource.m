#import "CatalogTableViewDataSource.h"

@interface CatalogTableViewDataSource (TypeNarrowing)

- (NSArray *)content;
- (void)setContent:(NSArray *)content;
- (NSArray *)arrangedObjects;

@end

@implementation CatalogTableViewDataSource

- (void)awakeFromNib
{
  self.content = @[
                   [[NSImage alloc] initWithContentsOfFile:@"/Applications/ComiketCatalog/DATA83/PDATA/0861.PNG"]
  ];
}

#pragma mark -
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return self.arrangedObjects.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  return self.arrangedObjects[row];
}

@end
