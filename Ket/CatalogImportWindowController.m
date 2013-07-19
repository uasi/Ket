#import "CatalogImportWindowController.h"

#import "CircleCutArchive.h"
#import "PathUtils.h"

static const char *kImportQueueLabel = "org.exsen.Ket.CatalogImportController.ImportQueue";

@interface CatalogImportWindowController ()

@property (nonatomic) IBOutlet NSTextField *databasePathTextField;
@property (nonatomic) IBOutlet NSTextField *archivePathTextField;
@property (nonatomic) IBOutlet NSButton *importButton;
@property (nonatomic) IBOutlet NSProgressIndicator *importProgressIndicator;

@property (nonatomic) BOOL isImportSuccess;

@end

@implementation CatalogImportWindowController

// TODO:
// - Make UI user friendly
//   - Disable Import button unless paths are entered
//   - Add Choose... button
//   - Show dialog when completed or aborted

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

- (void)importDBv2AtURL:(NSURL *)databaseURL andArchiveAtURL:(NSURL *)archiveURL ofComiketNo:(NSUInteger)comiketNo
{
  self.importButton.enabled = NO;
  [self.importProgressIndicator startAnimation:self];

  dispatch_queue_t importQueue = dispatch_queue_create(kImportQueueLabel, DISPATCH_QUEUE_CONCURRENT);
  self.isImportSuccess = YES;

  NSString *comiketID = ComiketIDFromComiketNo(comiketNo);

  // Launch convert tasks in the import queue. Each task will turn off
  // isImportSuccess if it fails.
  NSURL *newDatabaseURL = CatalogDatabaseURLWithComiketID(comiketID);
  [self convertDBv2AtURL:databaseURL toDBv3AtURL:newDatabaseURL withQueue:importQueue];

  dispatch_async(importQueue, ^{
    NSURL *newArchiveURL = CircleCutArchiveURLWithComiketID(comiketID);
    BOOL ok = [[NSFileManager defaultManager] copyItemAtURL:archiveURL toURL:newArchiveURL error:NULL];
    if (!ok) self.isImportSuccess = NO;
  });

  dispatch_barrier_async(importQueue, ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      self.importButton.enabled = YES;
      [self.importProgressIndicator stopAnimation:self];
      NSString *messageText;
      if (self.isImportSuccess) {
        messageText = [NSString stringWithFormat:@"Could not import %@ catalog",ComiketNameFromComiketNo(comiketNo)];
      }
      else {
        messageText = [NSString stringWithFormat:@"Imported %@ catalog successfully!", ComiketNameFromComiketNo(comiketNo)];
      }
      [[NSAlert alertWithMessageText:messageText defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
    });
  });
}

- (void)convertDBv2AtURL:(NSURL *)v2URL toDBv3AtURL:(NSURL *)v3URL withQueue:(dispatch_queue_t)queue
{
  dispatch_semaphore_t dumpTaskSema = dispatch_semaphore_create(0);
  dispatch_semaphore_t loadTaskSema = dispatch_semaphore_create(0);

  // Dispatch blocks that remain in the queue on behalf of the actual import
  // tasks.
  dispatch_async(queue, ^{
    dispatch_semaphore_wait(dumpTaskSema, DISPATCH_TIME_FOREVER);
  });
  dispatch_async(queue, ^{
    dispatch_semaphore_wait(loadTaskSema, DISPATCH_TIME_FOREVER);
  });

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
    NSLog(@"Dump task completed with status %d", dumpTask.terminationStatus);
    if (dumpTask.terminationStatus != 0) self.isImportSuccess = NO;
    dispatch_semaphore_signal(dumpTaskSema);
  };
  loadTask.terminationHandler = ^(NSTask *loadTask) {
    NSLog(@"Load task completed with status %d", loadTask.terminationStatus);
    if (loadTask.terminationStatus != 0) self.isImportSuccess = NO;
    dispatch_semaphore_signal(loadTaskSema);
  };

  EnsureDirectoryExistsAtURL(v3URL.URLByDeletingLastPathComponent);
  [dumpTask launch];
  [loadTask launch];
}

- (void)choosePathWithPathTextField:(NSTextField *)pathTextField fileType:(NSString *)fileType
{
  NSAssert(pathTextField != nil, @"pathTextField must not be nil");

  NSString *defaultPath = [(pathTextField.stringValue ?: @"") stringByDeletingLastPathComponent];
  BOOL isDirectory;
  if (![[NSFileManager defaultManager] fileExistsAtPath:defaultPath isDirectory:&isDirectory] || !isDirectory) {
    defaultPath = nil;
  }

  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  openPanel.canChooseFiles = YES;
  openPanel.canChooseDirectories = NO;
  openPanel.allowsMultipleSelection = NO;
  if (fileType) openPanel.allowedFileTypes = @[fileType];
  if (defaultPath) openPanel.directoryURL = [NSURL fileURLWithPath:defaultPath];

  [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
    if (result == NSFileHandlingPanelOKButton) {
      NSURL *fileURL = openPanel.URL;
      pathTextField.stringValue = fileURL.path;
    }
  }];
}

#pragma mark Actions

static void fail(NSString *messageText)
{
  [[NSAlert alertWithMessageText:messageText defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
}

- (IBAction)performImport:(id)sender
{
  NSURL *databaseURL = [NSURL fileURLWithPath:self.databasePathTextField.stringValue];
  NSURL *archiveURL = [NSURL fileURLWithPath:self.archivePathTextField.stringValue];

  if (!databaseURL) {
    fail(@"Invalid path to database");
    return;
  }
  if (!archiveURL) {
    fail(@"Invalid path to archive");
    return;
  }

  NSUInteger databaseComiketNo = [self comiketNoOfDBv2AtURL:databaseURL];
  NSUInteger archiveComiketNo = [self comiketNoOfArchiveAtURL:archiveURL];

  if (databaseComiketNo == 0) {
    fail(@"Could not load database");
    return;
  }
  if (archiveComiketNo == 0) {
    fail(@"Could not load archive");
    return;
  }
  if (databaseComiketNo != archiveComiketNo) {
    fail(@"Comiket number not matched");
    return;
  }

  [self importDBv2AtURL:databaseURL andArchiveAtURL:archiveURL ofComiketNo:databaseComiketNo];
}

- (IBAction)performChooseDatabase:(id)sender
{
  [self choosePathWithPathTextField:self.databasePathTextField fileType:@"DB"];
}

- (IBAction)performChooseArchive:(id)sender
{
  [self choosePathWithPathTextField:self.archivePathTextField fileType:@"CCZ"];
}

@end
