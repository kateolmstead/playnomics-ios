#import "BroadcastReceiver.h"
#import "Context.h"
#import "Intent.h"
#import "Log.h"

@interface ScreenReceiver : BroadcastReceiver {
  BOOL screenOff;
}

- (void) onReceive:(Context *)context intent:(Intent *)intent;
@end
