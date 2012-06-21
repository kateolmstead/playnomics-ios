#import <Foundation/Foundation.h>

#import "PlaynomicsEvent.h"

@interface ErrorEvent : PlaynomicsEvent {
  NSException * _e;
}

- (id) initWithE:(NSException *)_e;
@end
