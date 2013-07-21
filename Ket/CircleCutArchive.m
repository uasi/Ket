#import "CircleCutArchive.h"

#import "Circle.h"
#import <zipzap/zipzap.h>

@interface CircleCutArchive ()

@property (nonatomic, readwrite) NSUInteger comiketNo;
@property (nonatomic, readwrite) NSSize cutSize;

@property (nonatomic) ZZArchive *archive;
@property (nonatomic, copy) NSDictionary *fileNameToEntry;
@property (nonatomic) NSUInteger indexOfFirstCircleCutEntry;

@end

@implementation CircleCutArchive

- (instancetype)initWithURL:(NSURL *)URL
{
  self = [super init];
  if (!self) return nil;

  self.archive = [ZZArchive archiveWithContentsOfURL:URL];
  if (!self.archive) return nil;

  NSMutableDictionary *fileNameToEntry = [NSMutableDictionary dictionaryWithCapacity:self.archive.entries.count];
  NSUInteger index = 0;
  self.indexOfFirstCircleCutEntry = NSNotFound;

  for (ZZArchiveEntry *entry in self.archive.entries) {
    fileNameToEntry[entry.fileName] = entry;
    // Find the first entry which fileName matches to /^\d{6}\.PNG$/.
    if (self.indexOfFirstCircleCutEntry == NSNotFound && entry.fileName.length == 10) {
      self.indexOfFirstCircleCutEntry = index;
    }
    index++;
  }

  self.fileNameToEntry = fileNameToEntry;

  if (![self loadInitTxtFromEntry:self.fileNameToEntry[@"INIT.TXT"]]) return nil;

  return self;
}

- (instancetype)init
{
  @throw NSInternalInconsistencyException;
}

- (BOOL)loadInitTxtFromEntry:(ZZArchiveEntry *)entry
{
  NSString *initTxt = [[NSString alloc] initWithData:entry.data encoding:NSUTF8StringEncoding];

  NSString *pattern = @"(?x) ^ cmnum\\t(\\d+) \\r?\\n width\\t(\\d+) \\r?\\n height\\t(\\d+) $";
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
  NSTextCheckingResult *match = [regex firstMatchInString:initTxt options:0 range:NSMakeRange(0, initTxt.length)];
  if (!match) return NO;

  // cmnum
  NSRange range = [match rangeAtIndex:1];
  self.comiketNo = [initTxt substringWithRange:range].integerValue;

  // width & height
  range = [match rangeAtIndex:2];
  CGFloat width = [initTxt substringWithRange:range].doubleValue;
  range = [match rangeAtIndex:3];
  CGFloat height = [initTxt substringWithRange:range].doubleValue;
  self.cutSize = NSMakeSize(width, height);

  return YES;
}

- (NSImage *)imageForCircle:(Circle *)circle
{
  NSUInteger entryIndex = self.indexOfFirstCircleCutEntry + (circle.identifier - 1);
  return [[NSImage alloc] initWithData:((ZZArchiveEntry *)self.archive.entries[entryIndex]).data];
}

@end
