@class Circle;

@interface CircleCutArchive : NSObject

@property (nonatomic, readonly, assign) NSUInteger comiketNo;
@property (nonatomic, readonly, assign) NSSize cutSize;

+ (CircleCutArchive *)archiveWithContentsOfURL:(NSURL *)URL;

- (NSImage *)imageForCircle:(Circle *)circle;

@end
