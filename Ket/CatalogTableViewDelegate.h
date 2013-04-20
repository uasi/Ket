@interface CatalogTableViewDelegate : NSObject <NSTableViewDelegate, NSTableViewDataSource>

@property (weak, nonatomic) IBOutlet NSTableView *tableView;

@end
