@class CSVChecklistV2Scanner;

@protocol CSVChecklistV2ScannerDelegate <NSObject>

@optional
- (void)checklistScannerWillScanRecord:(CSVChecklistV2Scanner *)scanner;
- (void)checklistScannerDidScanRecord:(CSVChecklistV2Scanner *)scanner;
- (void)checklistScannerWilScanField:(CSVChecklistV2Scanner *)scanner;
- (void)checklistScanner:(CSVChecklistV2Scanner *)scanner didScanFieldWithStringValue:(NSString *)stringValue;

@end

@interface CSVChecklistV2Scanner : NSObject

@property (nonatomic, weak) id<CSVChecklistV2ScannerDelegate> delegate;
@property (nonatomic, readonly) NSString *string;
@property (nonatomic, readonly) NSUInteger location;

- (instancetype)initWithString:(NSString *)string;
- (void)scan;

@end
