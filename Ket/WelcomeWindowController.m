#import "WelcomeWindowController.h"

#import "NSRegularExpression+Extensions.h"
#import "PathUtils.h"

@interface WelcomeWindowController ()

@property (nonatomic) IBOutlet NSTableView *catalogListTableView;

@property (nonatomic, copy) NSArray *cachedCatalogNames;

@end

@implementation WelcomeWindowController

- (instancetype)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (!self) return nil;
  self.cachedCatalogNames = [self catalogNames];
  return self;
}

- (NSArray *)catalogURLs
{
  NSArray *URLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:CatalogsDirectoryURL() includingPropertiesForKeys:@[NSURLIsDirectoryKey] options:0 error:NULL];
  if (!URLs) {
    DDLogError(@"Could not list imported catalogs");
    return @[];
  }
  NSMutableArray *catalogURLs = [NSMutableArray array];
  for (NSURL *URL in URLs) {
    NSNumber *isDirectory;
    [URL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
    BOOL hasCorrectName = [NSRegularExpression testString:URL.lastPathComponent withPattern:@"^C\\d{2,3}$"];
    if ([isDirectory boolValue] && hasCorrectName) {
      [catalogURLs addObject:URL];
    }
  }
  NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastPathComponent" ascending:NO selector:@selector(localizedStandardCompare:)];
  return [catalogURLs sortedArrayUsingDescriptors:@[descriptor]];
}

- (NSArray *)catalogNames
{
  return [[[[self catalogURLs] rac_sequence] map:^NSString *(NSURL *URL) {
    NSUInteger comiketNo = ComiketNoFromString(URL.lastPathComponent);
    return ComiketNameFromComiketNo(comiketNo);
  }] array];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return self.cachedCatalogNames.count + 1;
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSString *identifier = (row < [self numberOfRowsInTableView:tableView] - 1 ?
                          @"CatalogListItemCell" :
                          @"CatalogListImportCell");
  NSTableCellView *view = [tableView makeViewWithIdentifier:identifier owner:nil];
  if ([identifier isEqualToString:@"CatalogListItemCell"]) {
    view.textField.stringValue = self.cachedCatalogNames[row];
    view.objectValue = self.cachedCatalogNames[row];
  }
  return view;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
  return 78;
}

@end
