@interface CircleCollection : NSObject

@property (nonatomic, readonly, copy) NSArray *circles;
@property (nonatomic, readonly, copy) NSArray *circlesPaddedWithNull;
@property (nonatomic, readonly) NSUInteger page;

- (instancetype)initWithCircles:(NSArray *)circles
                cutCountPerPage:(NSUInteger)count;

@end
