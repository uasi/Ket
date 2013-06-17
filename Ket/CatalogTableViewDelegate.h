@class Circle;

@interface CatalogTableViewDelegate : NSObject <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, readonly) Circle *selectedCircle;

@end
