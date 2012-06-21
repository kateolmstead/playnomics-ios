#import "ScreenReceiver.h"

NSString * TAG = [[ScreenReceiver class] simpleName];

@implementation ScreenReceiver

- (void) onReceive:(Context *)context intent:(Intent *)intent {
  if ([[intent action] isEqualTo:Intent.ACTION_SCREEN_OFF]) {
    screenOff = YES;
    [PlaynomicsSession pause];
    [Log i:TAG param1:@"SCREEN TURNED OFF"];
  }
   else if ([[intent action] isEqualTo:Intent.ACTION_SCREEN_ON]) {
    screenOff = NO;
    [Log i:TAG param1:@"SCREEN TURNED ON"];
  }
}

@end
