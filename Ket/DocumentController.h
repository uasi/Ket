@class CatalogImportWindowController;
@class WelcomeWindowController;

@interface DocumentController : NSDocumentController

@property (nonatomic, readonly) CatalogImportWindowController *catalogImportWindowController;
@property (nonatomic, readonly) WelcomeWindowController *welcomeWindowController;

- (id)openUntitledDocumentAndDisplay:(BOOL)displayDocument withComiketNo:(NSUInteger)comiketNo error:(NSError **)outError;

@end

@interface DocumentController (TypeNarrowing)

+ (instancetype)sharedDocumentController; // narrowed down from +(id).

@end