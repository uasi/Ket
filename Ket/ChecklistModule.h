#import <sqlite3.h>

@class Checklist;

int ChecklistModuleInit(sqlite3 *db);
NSString *ChecklistModuleName(void);
void ChecklistModuleRegisterChecklistWeakRef(Checklist *checklist);
