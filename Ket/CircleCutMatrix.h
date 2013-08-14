extern NSString *const CircleCutMatrixDidSelectCellNotification;

@class Checklist;
@class CircleCutCell;

@interface CircleCutMatrix : NSMatrix

@property (nonatomic, readonly) Checklist *checklist;
@property (nonatomic) CircleCutCell *highlightedCircleCutCell;

- (void)prepareMatrixWithChecklist:(Checklist *)checklist;
- (void)unhighlightAllCells;

@end
