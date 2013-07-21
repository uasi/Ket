@class Circle;

@interface Document : NSDocument

@property (nonatomic, readonly) NSUInteger comiketNo;
@property (nonatomic, readonly) NSMutableDictionary *bookmarks;
@property (nonatomic, readonly) Circle *selectedCircle;

- (void)prepareDocumentWithComiketNo:(NSUInteger)comiketNo;

@end

