@interface Document : NSDocument

@property (nonatomic, readonly) NSMutableDictionary *bookmarks;

// May receive this message as the first responder.
- (IBAction)showCircleInspector:(id)sender;

@end

