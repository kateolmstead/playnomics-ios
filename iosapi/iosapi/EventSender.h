#import <Foundation/Foundation.h>

#import "PlaynomicsEvent.h"

@interface EventSender : NSObject {
  NSString * _version;
  NSString * _baseUrl;
  NSTimeInterval _connectTimeout;
  BOOL _testMode;
}

- (id) initWithTestMode:(BOOL)testMode;
- (BOOL) sendToServer:(NSString *)eventUrl;
- (BOOL) sendEventToServer:(PlaynomicsEvent *)pe;
@end
