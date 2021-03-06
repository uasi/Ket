@class CatalogImportWindowController;
@class Checklist;
@class CircleInspectorController;
@class SearchPanelController;
@class WelcomeWindowController;

@interface DocumentController : NSDocumentController

@property (nonatomic, readonly) CatalogImportWindowController *catalogImportWindowController;
@property (nonatomic, readonly) CircleInspectorController *circleInspectorController;
@property (nonatomic, readonly) SearchPanelController *searchPanelController;
@property (nonatomic, readonly) WelcomeWindowController *welcomeWindowController;

- (id)openUntitledDocumentAndDisplay:(BOOL)displayDocument withComiketNo:(NSUInteger)comiketNo error:(NSError **)outError;
- (id)openUntitledDocumentAndDisplay:(BOOL)displayDocument withChecklist:(Checklist *)checklist error:(NSError **)outError;

- (IBAction)showCircleInspector:(id)sender;
- (IBAction)showSearchPanelForGenericSearch:(id)sender;
- (IBAction)showSearchPanelForAddressSearch:(id)sender;
- (IBAction)showSearchPanelForLabelSearch:(id)sender;

@end

@interface DocumentController (TypeNarrowing)

+ (instancetype)sharedDocumentController; // narrowed down from +(id).

@end