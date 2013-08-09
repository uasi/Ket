#import "ChecklistModule.h"

#import "Checklist.h"
#import "Circle.h"

#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <assert.h>
#import <sqlite3.h>

#define TABLE_DECLARATION "CREATE TABLE x(comiketNo,id,bookmarked,colorCode,note)"
#define COLUMN_INDEX_rowid (-1)
#define COLUMN_INDEX_comiketNo 0
#define COLUMN_INDEX_id 1
#define COLUMN_INDEX_bookmarked 2
#define COLUMN_INDEX_colorCode 3
#define COLUMN_INDEX_note 4

static NSMapTable *checklistMapTable;

typedef struct checklist_vtab checklist_vtab;
typedef struct checklist_cursor checklist_cursor;

struct checklist_vtab
{
  sqlite3_vtab base;
  char *zClassName;
  int nCursor;

  CFTypeRef pChecklist;
};

struct checklist_cursor
{
  sqlite3_vtab_cursor base;
  checklist_vtab *pTab;

  CFTypeRef pChecklistSnapshot;
  NSUInteger *aGlobalID;
  NSUInteger nGlobalID;
  NSUInteger iGlobalID;
};

static void checklistTabFree(checklist_vtab *pTab)
{
  if (!pTab) return;
  if (pTab->pChecklist) CFRelease(pTab->pChecklist);
  sqlite3_free(pTab->zClassName);
  sqlite3_free(pTab);
}

// argv[0] == module name
// argv[1] == database name
// argv[2] == table name
// argv[3] == checklist identifier
static int checklistConnect(sqlite3 *db,
                            void *pAux,
                            int argc,
                            const char *const *argv,
                            sqlite3_vtab **ppVTab,
                            char **pzErr)
{
  int rc = SQLITE_OK;
  checklist_vtab *pNewTab = NULL;
  const char *zModule = argv[0];

  *ppVTab = NULL;
  pNewTab = sqlite3_malloc(sizeof(*pNewTab));
  if (!pNewTab) {
    return SQLITE_NOMEM;
  }
  memset(pNewTab, 0, sizeof(*pNewTab));
  pNewTab->zClassName = sqlite3_mprintf("%s", zModule);

  rc = sqlite3_declare_vtab(db, TABLE_DECLARATION);
  if (rc != SQLITE_OK) {
    checklistTabFree(pNewTab);
    return rc;
  }

  if (argc < 4) {
    *pzErr = sqlite3_mprintf("%s: checklist identifier must be specified as the first argument",
                             pNewTab->zClassName);
    checklistTabFree(pNewTab);
    return SQLITE_MISUSE;
  }

  const char *zIdentifier = argv[3];
  NSString *identifier = [NSString stringWithUTF8String:zIdentifier];
  Checklist *checklist = [checklistMapTable objectForKey:identifier];
  if (checklist) {
    pNewTab->pChecklist = CFBridgingRetain(checklist);
  }
  else {
    *pzErr = sqlite3_mprintf("%s: no checklist found for %s in %s",
                             pNewTab->zClassName,
                             zIdentifier,
                             checklistMapTable.description.UTF8String);
    checklistTabFree(pNewTab);
    return SQLITE_MISUSE;
  }

  *ppVTab = (sqlite3_vtab *)pNewTab;
  return SQLITE_OK;
}

static int checklistDisconnect(sqlite3_vtab *pVTab)
{
  checklistTabFree((checklist_vtab *)pVTab);
  return SQLITE_OK;
}

static int checklistBestIndex(sqlite3_vtab *pVTab, sqlite3_index_info *pIdxInfo)
{
  const struct sqlite3_index_orderby *pOrderBy;
  pOrderBy = pIdxInfo->aOrderBy;
  pIdxInfo->orderByConsumed = 1; // by default the table is ordered by id.
  for (int i = 0; i < pIdxInfo->nOrderBy; i++, pOrderBy++) {
    switch (pOrderBy->iColumn) {
      case COLUMN_INDEX_comiketNo: {
        // Every value in the comiketNo column must be the same, so no-op.
        break;
      }
      case COLUMN_INDEX_id: {
        pIdxInfo->orderByConsumed = !pOrderBy->desc;
        // If an ORDER BY clause on the id column appears before any other
        // OEDER BYs (except for ones on the comiketNo column, which are no-op),
        // following ORDER BYs will make no differences.
        goto finish_consume_orderby;
      }
      case COLUMN_INDEX_bookmarked: {
        // We don't attempt to order by the bookmarked column.
        pIdxInfo->orderByConsumed = 0;
        goto finish_consume_orderby;
      }
      case COLUMN_INDEX_colorCode: {
        // Ditto.
        pIdxInfo->orderByConsumed = 0;
        goto finish_consume_orderby;
      }
      case COLUMN_INDEX_note: {
        // You see.
        pIdxInfo->orderByConsumed = 0;
        goto finish_consume_orderby;
      }
      default: {
        assert(0);
        return SQLITE_ERROR;
      }
    }
  }
finish_consume_orderby:

  pIdxInfo->idxNum = 0;
  pIdxInfo->idxStr = NULL;
  pIdxInfo->needToFreeIdxStr = 0;
  pIdxInfo->estimatedCost = 10000.0;

  return SQLITE_OK;
}

static void checklistCursorFree(checklist_cursor *pCur)
{
  if (!pCur) return;
  if (pCur->pTab) pCur->pTab->nCursor--;
  if (pCur->pChecklistSnapshot) CFRelease(pCur->pChecklistSnapshot);
  if (pCur->aGlobalID) CFAllocatorDeallocate(NULL, pCur->aGlobalID);
  sqlite3_free(pCur);
}

static int checklistOpen(sqlite3_vtab *pVTab, sqlite3_vtab_cursor **ppCursor)
{
  checklist_vtab *pTab = (checklist_vtab *)pVTab;

  // Create a cursor.
  checklist_cursor *pCur = sqlite3_malloc(sizeof(*pCur));
  if (!pCur) return SQLITE_NOMEM;
  memset(pCur, 0, sizeof(*pCur));

  // Set a snapshot of the checklist to the cursor.
  id<ChecklistReading> snapshot = ((__bridge Checklist *)pTab->pChecklist).snapshot;
  pCur->pChecklistSnapshot = CFBridgingRetain(snapshot);

  // Set an array of global IDs to the cursor.
  NSUInteger maxCount = snapshot.globalIDSet.count;
  if (maxCount > 0) {
    NSRange range = NSMakeRange(0, NSUIntegerMax);
    pCur->aGlobalID = CFAllocatorAllocate(NULL, sizeof(NSUInteger) * maxCount, 0);
    if (!pCur->aGlobalID) {
      checklistCursorFree(pCur);
      return SQLITE_NOMEM;
    }
    pCur->nGlobalID = [snapshot.globalIDSet getIndexes:pCur->aGlobalID maxCount:maxCount inIndexRange:&range];
    pCur->iGlobalID = 0;
  }
  else {
    pCur->aGlobalID = NULL;
    pCur->nGlobalID = 0;
    pCur->iGlobalID = 0;
  }

  pTab->nCursor++;
  *ppCursor = &pCur->base;
  return SQLITE_OK;
}

static int checklistClose(sqlite3_vtab_cursor *pCursor)
{
  checklistCursorFree((checklist_cursor *)pCursor);
  return SQLITE_OK;
}

static int checklistFilter(sqlite3_vtab_cursor *pCursor,
                           int idxNum,
                           const char *idxStr,
                           int argc,
                           sqlite3_value **argv)
{
  checklist_cursor *pCur = (checklist_cursor *)pCursor;
  pCur->iGlobalID = 0;
  return SQLITE_OK;
}

static int checklistNext(sqlite3_vtab_cursor *pCursor)
{
  checklist_cursor *pCur = (checklist_cursor *)pCursor;
  pCur->iGlobalID++;
  return SQLITE_OK;
}

static int checklistEof(sqlite3_vtab_cursor *pCursor)
{
  checklist_cursor *pCur = (checklist_cursor *)pCursor;
  return pCur->iGlobalID >= pCur->nGlobalID;
}

static int checklistColumn(sqlite3_vtab_cursor *pCursor, sqlite3_context *ctx, int i)
{
  checklist_cursor *pCur = (checklist_cursor *)pCursor;
  id<ChecklistReading> snapshot = (__bridge id)pCur->pChecklistSnapshot;
  NSUInteger globalID = pCur->aGlobalID[pCur->iGlobalID];

  switch (i) {
    case COLUMN_INDEX_comiketNo: {
      sqlite3_result_int64(ctx, (sqlite3_int64)ComiketNoFromGlobalCircleID(globalID));
      break;
    }
    case COLUMN_INDEX_id: {
      sqlite3_result_int64(ctx, (sqlite3_int64)CircleIdentifierFromGlobalCircleID(globalID));
      break;
    }
    case COLUMN_INDEX_bookmarked: {
      BOOL bookmarked = [snapshot.globalIDSet containsIndex:globalID];
      sqlite3_result_int(ctx, bookmarked);
      break;
    }
    case COLUMN_INDEX_colorCode: {
      NSInteger colorCode = [snapshot colorCodeForCircleWithGlobalID:globalID];
      sqlite3_result_int64(ctx, (sqlite_int64)colorCode);
      break;
    }
    case COLUMN_INDEX_note: {
      NSString *note = [snapshot noteForCircleWithGlobalID:globalID];
      if (note) {
        const char *zNote = sqlite3_mprintf("%s", [note UTF8String]);
        if (!zNote) return SQLITE_NOMEM;
        sqlite3_result_text(ctx, zNote, -1, sqlite3_free);
      }
      else {
        sqlite3_result_null(ctx);
      }
      break;
    }
    default: {
      assert(0);
      sqlite3_result_null(ctx);
      break;
    }
  }

  return SQLITE_OK;
}

static int checklistRowid(sqlite3_vtab_cursor *pCursor, sqlite_int64 *pRowid)
{
  checklist_cursor *pCur = (checklist_cursor*)pCursor;
  *pRowid = (sqlite_int64)pCur->aGlobalID[pCur->nGlobalID];
  return SQLITE_OK;
}

static sqlite3_module checklist_module = {
  0,                   // xVersion
  checklistConnect,    // xCreate
  checklistConnect,    // xConnect
  checklistBestIndex,  // xBestIndex
  checklistDisconnect, // xDisconnect
  checklistDisconnect, // xDestroy
  checklistOpen,       // xOpen
  checklistClose,      // xClose
  checklistFilter,     // xFilter
  checklistNext,       // xNext
  checklistEof,        // xEof
  checklistColumn,     // xColumn
  checklistRowid,      // xRowid
  NULL,                // xUpdate
  NULL,                // xBegin
  NULL,                // xSync
  NULL,                // xCommit
  NULL,                // xRollback
  NULL,                // xFindFunction
  NULL,                // xRename
};

#define CHECKLIST_MODULE_NAME "checklist"

int ChecklistModuleInit(sqlite3 *db)
{
  NSCAssert(db, @"db must not be nil");
  if (!checklistMapTable) checklistMapTable = [NSMapTable strongToWeakObjectsMapTable];
  return sqlite3_create_module(db, CHECKLIST_MODULE_NAME, &checklist_module, NULL);
}

NSString *ChecklistModuleName(void)
{
  return @CHECKLIST_MODULE_NAME;
}

void ChecklistModuleRegisterChecklistWeakRef(Checklist *checklist)
{
  NSCAssert(checklistMapTable, @"ChecklistModule must be initialized");
  NSCAssert(checklist, @"checklist must not be nil");
  [checklistMapTable setObject:checklist forKey:checklist.identifier];
}
