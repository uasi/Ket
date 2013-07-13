extern NSString *const CircleCutMatrixDidSelectCellNotification;

@class CircleCutCell;

@interface CircleCutMatrix : NSMatrix

@property (nonatomic) CircleCutCell *highlightedCircleCutCell;

- (void)unhighlightAllCells;

@end
