@class CatalogDatabase;
@class CatalogFilter;
@class Checklist;
@class Circle;
@class CircleCollection;

@interface CircleDataProvider : NSObject

@property (nonatomic, readonly) NSUInteger comiketNo;
@property (nonatomic, readonly) Checklist *checklist;
@property (nonatomic, readonly) CatalogDatabase *database;
@property (nonatomic, readonly) NSSize cutSize;
@property (nonatomic, readonly) NSUInteger numberOfCutsInRow;
@property (nonatomic, readonly) NSUInteger numberOfCutsInColumn;
@property (nonatomic, readonly) RACSignal *dataDidChangeSignal;
@property (nonatomic) CatalogFilter *filter;

- (instancetype)initWithChecklist:(Checklist *)checklist;

- (NSInteger)numberOfRows;
- (CircleCollection *)circleCollectionForRow:(NSInteger)row;
- (NSString *)stringValueForGroupRow:(NSInteger)row;
- (BOOL)isGroupRow:(NSInteger)row;
- (NSString *)blockNameForID:(NSInteger)blockID;
- (NSImage *)imageForCircle:(Circle *)circle;
- (void)filterWithString:(NSString *)string;

@end
