#import <Foundation/Foundation.h>

@interface ErrorEvent : PlaynomicsEvent {
  NSException * e;
}

- (id) initWithE:(NSException *)e;
- (NSString *) toQueryString;
@end
