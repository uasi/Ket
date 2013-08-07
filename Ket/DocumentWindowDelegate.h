@protocol DocumentWindowDelegate <NSObject>

- (BOOL)window:(NSWindow *)window shouldPropagateKeyDown:(NSEvent *)event;

@end