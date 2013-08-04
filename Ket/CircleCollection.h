@interface CircleCollection : NSObject

@property (nonatomic, copy, readonly) NSArray *nonEmptyCircles;
@property (nonatomic, copy, readonly) NSArray *circles;
@property (nonatomic, readonly) NSString *summary;

- (instancetype)initWithCircles:(NSArray *)circles count:(NSUInteger)count respectsCutIndex:(BOOL)respectsCutIndex;

- (NSString *)summary;

@end
