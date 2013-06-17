@class Circle;

@interface Document : NSDocument

@property (nonatomic, readonly) NSMutableDictionary *bookmarks;
@property (nonatomic, readonly) Circle *selectedCircle;

// May receive this message as the first responder.
- (IBAction)showCircleInspector:(id)sender;

@end

