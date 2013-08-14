@class CatalogDatabase;
@class Checklist;

@interface CSVChecklistV2Writer : NSObject

+ (BOOL)writeChecklist:(Checklist *)checklist withDatabase:(CatalogDatabase *)databse toURL:(NSURL *)URL error:(NSError **)error;

@end
