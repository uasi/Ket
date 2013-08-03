@class Checklist;
@class Circle;
@class Document;

@interface CircleInspectorController : NSWindowController <NSWindowDelegate>

@property (nonatomic, readonly) Circle *circle;
@property (nonatomic, readonly) Checklist *checklist;

@property (nonatomic, getter = isBookmarked, setter = setBookmarked:) BOOL bookmarked;

@end

@interface CircleInspectorController (TypeNarrowing)

@property (nonatomic) Document *document; // narrowed down from -(id)document.

@end
