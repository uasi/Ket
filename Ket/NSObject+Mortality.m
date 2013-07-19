#import "NSObject+Mortality.h"

#import <objc/runtime.h>

@implementation NSObject (Mortality)

static const char mortalityKey;

- (instancetype)makeImmortal
{
  objc_setAssociatedObject(self, &mortalityKey, self, OBJC_ASSOCIATION_RETAIN);
  return self;
}

- (instancetype)makeMortal
{
  objc_setAssociatedObject(self, &mortalityKey, nil, 0);
  return self;
}

- (BOOL)isMortal
{
  return !!objc_getAssociatedObject(self, &mortalityKey);
}
@end
