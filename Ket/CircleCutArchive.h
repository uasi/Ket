@class Circle;

@interface CircleCutArchive : NSObject

@property (readonly, assign, nonatomic) NSUInteger comiketNo;
@property (readonly, assign, nonatomic) NSSize cutSize;

+ (CircleCutArchive *)archiveWithContentsOfURL:(NSURL *)URL;

- (NSImage *)imageForCircle:(Circle *)circle;

@end
