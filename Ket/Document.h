@class Circle;

@interface Document : NSDocument

@property (nonatomic, readonly) NSUInteger comiketNo;
@property (nonatomic, readonly) NSMutableDictionary *bookmarks;
@property (nonatomic, readonly) Circle *selectedCircle;

- (void)prepareDocumentWithComiketNo:(NSUInteger)comiketNo;

// May receive this message as the first responder.
- (IBAction)showCircleInspector:(id)sender;

@end

