#import <Foundation/Foundation.h>

#import "PNEvent.h"
#import "PNSession.h"

@interface PNEventApiClient : NSObject
- (id) initWithSession: (PNSession *) session;
- (void) enqueueEvent: (PNEvent *) event;
- (void) enqueueEventUrl: (NSString *) url;

- (void) onEventWasCanceled: (NSString *) url;

- (NSSet *) getAllUnprocessedUrls;
//queue processing
- (void) start;
- (void) pause;
- (void) stop;
@end
