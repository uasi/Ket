#import "CatalogImportWindowController.h"

#import "CircleCutArchive.h"
#import "PathUtils.h"

@interface CatalogImportWindowController ()

@property (nonatomic) IBOutlet NSTextField *databasePathTextField;
@property (nonatomic) IBOutlet NSTextField *archivePathTextField;

@end

@implementation CatalogImportWindowController

// TODO:
// - Make UI user friendly
//   - Disable Import button unless paths are entered
//   - Add Choose... button
//   - Show dialog when completed or aborted

- (IBAction)performImport:(id)sender
{
  NSURL *databaseURL = [NSURL fileURLWithPath:self.databasePathTextField.stringValue];
  NSURL *archiveURL = [NSURL fileURLWithPath:self.archivePathTextField.stringValue];

  NSUInteger databaseComiketNo = [self comiketNoOfDBv2AtURL:databaseURL];
  NSUInteger archiveComiketNo = [self comiketNoOfArchiveAtURL:archiveURL];

  if (databaseComiketNo == 0) {
    NSLog(@"Failed to load database");
    return;
  }
  if (archiveComiketNo == 0) {
    NSLog(@"Failed to load archive");
    return;
  }
  if (databaseComiketNo != archiveComiketNo) {
    NSLog(@"Comiket number not matched");
    return;
  }

  NSString *comiketID = ComiketIDFromComiketNo(databaseComiketNo);
  NSURL *newDatabaseURL = CatalogDatabaseURLWithComiketID(comiketID);
  [self convertDBv2AtURL:databaseURL toDBv3AtURL:newDatabaseURL];

  NSURL *newArchiveURL = CircleCutArchiveURLWithComiketID(comiketID);
  BOOL ok = [[NSFileManager defaultManager] copyItemAtURL:archiveURL toURL:newArchiveURL error:NULL];
  if (!ok) (void)0;
}

static inline NSString *sqlitePath() {
  return [[NSBundle mainBundle] URLForAuxiliaryExecutable:@"sqlite-wrapper"].path;
}

- (NSUInteger)comiketNoOfDBv2AtURL:(NSURL *)URL
{
  NSTask *task = [[NSTask alloc] init];
  task.launchPath = sqlitePath();
  task.arguments = @[URL.path, @"SELECT comiketNo FROM ComiketInfo;"];

  NSPipe *pipe = [NSPipe pipe];
  task.standardOutput = pipe;

  [task launch];
  [task waitUntilExit];
  if ([task terminationStatus] != 0) return 0;

  NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
  NSString *comiketNoString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSInteger comiketNo;
  BOOL ok = [[NSScanner scannerWithString:comiketNoString] scanInteger:&comiketNo];
  if (!ok) return 0;

  return (NSUInteger)comiketNo;
}

- (NSUInteger)comiketNoOfArchiveAtURL:(NSURL *)URL
{
  CircleCutArchive *archive = [CircleCutArchive archiveWithContentsOfURL:URL];
  if (!archive) return 0;
  return archive.comiketNo;
}

// TODO: add completion handler
- (void)convertDBv2AtURL:(NSURL *)v2URL toDBv3AtURL:(NSURL *)v3URL
{
  NSTask *dumpTask = [[NSTask alloc] init];
  dumpTask.launchPath = sqlitePath();
  dumpTask.arguments = @[v2URL.path, @".dump"];

  NSTask *loadTask = [[NSTask alloc] init];
  loadTask.launchPath = @"/usr/bin/sqlite3";
  loadTask.arguments = @[v3URL.path];

  NSPipe *pipe = [NSPipe pipe];
  dumpTask.standardOutput = pipe;
  loadTask.standardInput = pipe;

  dumpTask.terminationHandler = ^(NSTask *dumpTask) {
    NSLog(@"Dumptask completed with status %d", dumpTask.terminationStatus);
  };
  loadTask.terminationHandler = ^(NSTask *loadTask) {
    NSLog(@"Loadtask completed with status %d", loadTask.terminationStatus);
  };

  [dumpTask launch];
  [loadTask launch];
}

@end
