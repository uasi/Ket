@class Circle;
@class CircleCollection;

@interface CircleDataProvider : NSObject

@property (nonatomic, readonly) NSUInteger comiketNo;
@property (nonatomic, readonly) NSSize cutSize;
@property (nonatomic, readonly) NSUInteger numberOfCutsInRow;
@property (nonatomic, readonly) NSUInteger numberOfCutsInColumn;
@property (nonatomic, readonly) RACSignal *dataDidChangeSignal;

- (instancetype)initWithComiketNo:(NSUInteger)comiketNo;

- (NSInteger)numberOfRows;
- (CircleCollection *)circleCollectionForRow:(NSInteger)row;
- (NSString *)stringValueForGroupRow:(NSInteger)row;
- (BOOL)isGroupRow:(NSInteger)row;
- (NSString *)blockNameForID:(NSInteger)blockID;
- (NSImage *)imageForCircle:(Circle *)circle;

- (void)filterUsingString:(NSString *)string;

@end
