@interface CircleCollection : NSObject

@property (readonly, copy, nonatomic) NSArray *circles;
@property (readonly, copy, nonatomic) NSArray *circlesPaddedWithNull;
@property (readonly, nonatomic) NSUInteger page;

- (instancetype)initWithCircles:(NSArray *)circles
                cutCountPerPage:(NSUInteger)count;

@end
