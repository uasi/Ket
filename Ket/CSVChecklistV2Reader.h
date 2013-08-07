@class Checklist;

@interface CSVChecklistV2Reader : NSObject

+ (Checklist *)checklistWithContentsOfURL:(NSURL *)URL error:(NSError **)error;

@end
