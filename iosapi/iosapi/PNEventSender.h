#import <Foundation/Foundation.h>

#import "PNEvent.h"

@interface PNEventSender : NSObject {
  NSString * _version;
  NSString * _baseUrl;
  NSTimeInterval _connectTimeout;
  BOOL _testMode;
}

@property (atomic, assign) BOOL testMode;

- (id) initWithTestMode:(BOOL)testMode;
- (void) sendEventToServer:(PNEvent *)pe withEventQueue: (NSMutableArray *) eventQueue;
@end
