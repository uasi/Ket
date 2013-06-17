extern NSString *const CircleCutMatrixDidSelectCellNotification;

@class CircleCutCell;

@interface CircleCutMatrix : NSMatrix

@property (nonatomic, readonly) CircleCutCell *highlightedCircleCutCell;

@end
