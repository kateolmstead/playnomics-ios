#import <Foundation/Foundation.h>

#import "PNEvent.h"

@interface PNEventSender : NSObject {
  NSTimeInterval _connectTimeout;
}

- (void) sendEventToServer:(PNEvent *)pe withEventQueue: (NSMutableArray *) eventQueue;
@end
