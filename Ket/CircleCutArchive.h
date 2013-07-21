@class Circle;

@interface CircleCutArchive : NSObject

@property (nonatomic, readonly) NSUInteger comiketNo;
@property (nonatomic, readonly) NSSize cutSize;

- (instancetype)initWithURL:(NSURL *)URL;

- (NSImage *)imageForCircle:(Circle *)circle;

@end
