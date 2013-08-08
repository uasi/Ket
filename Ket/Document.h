#import "DocumentWindowDelegate.h"

@class Checklist;
@class Circle;
@class CircleDataProvider;

@interface Document : NSDocument <DocumentWindowDelegate>

@property (nonatomic, readonly) NSUInteger comiketNo;
@property (nonatomic, readonly) NSMutableDictionary *bookmarks;
@property (nonatomic, readonly) Circle *selectedCircle;
@property (nonatomic, readonly) CircleDataProvider *circleDataProvider;
@property (nonatomic, readonly) Checklist *checklist;

- (void)prepareDocumentWithComiketNo:(NSUInteger)comiketNo;
- (IBAction)performExportAction:(id)sender;

@end

