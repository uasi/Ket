@class Circle;
@class CircleDataProvider;

@interface Document : NSDocument

@property (nonatomic, readonly) NSUInteger comiketNo;
@property (nonatomic, readonly) NSMutableDictionary *bookmarks;
@property (nonatomic, readonly) Circle *selectedCircle;
@property (nonatomic, readonly) CircleDataProvider *circleDataProvider;

- (void)prepareDocumentWithComiketNo:(NSUInteger)comiketNo;

@end

