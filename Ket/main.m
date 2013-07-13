#import <Cocoa/Cocoa.h>

// Global log level.
#ifdef DEBUG
int ddLogLevel = LOG_LEVEL_INFO;
#else
int ddLogLevel = LOG_LEVEL_ERROR;
#endif

int main(int argc, char *argv[])
{
  return NSApplicationMain(argc, (const char **)argv);
}
