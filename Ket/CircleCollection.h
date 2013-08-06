@interface CircleCollection : NSObject

@property (nonatomic, copy, readonly) NSArray *nonEmptyCircles;
@property (nonatomic, copy, readonly) NSArray *circles;
@property (nonatomic, readonly) NSString *summary;

+ (CircleCollection *)emptyCircleCollectionWithMaxCount:(NSUInteger)maxCount;

- (instancetype)initWithCircles:(NSArray *)circles maxCount:(NSUInteger)count respectsCutIndex:(BOOL)respectsCutIndex;

- (NSString *)summary;

@end
