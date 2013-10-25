#import "DocumentWindowDelegate.h"

@class Checklist;
@class Circle;
@class CircleDataProvider;

@interface Document : NSDocument <DocumentWindowDelegate>

@property (nonatomic, readonly) NSUInteger comiketNo;
@property (nonatomic, readonly) NSMutableDictionary *bookmarks;
@property (nonatomic, readonly) CircleDataProvider *circleDataProvider;
@property (nonatomic, readonly) Checklist *checklist;

- (void)prepareDocumentWithComiketNo:(NSUInteger)comiketNo;
- (void)prepareDocumentWithChecklist:(Checklist *)checklist;
- (IBAction)performImportAction:(id)sender;
- (IBAction)performExportAction:(id)sender;

@end

