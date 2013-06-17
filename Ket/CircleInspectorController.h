#import "Circle.h"
#import "Document.h"

@interface CircleInspectorController : NSWindowController <NSWindowDelegate>

@property (nonatomic, readonly) Circle *circle;
@property (nonatomic, setter = setBookmarked:) BOOL isBookmarked;

@end

@interface CircleInspectorController (TypeNarrowing)

@property (nonatomic) Document *document; // narrowed down from -(id)document.

@end
