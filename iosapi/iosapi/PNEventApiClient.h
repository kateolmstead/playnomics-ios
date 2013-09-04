#import <Foundation/Foundation.h>

#import "PNEvent.h"
#import "PNSession.h"
#import "PNUrlProcessorDelegate.h"

@interface PNEventApiClient : NSObject<PNUrlProcessorDelegate>
- (id) initWithSession: (PNSession *) session;
- (void) enqueueEvent: (PNEvent *) event;
- (void) enqueueEventUrl: (NSString *) url;

- (NSSet *) getAllUnprocessedUrls;
//queue processing
- (void) start;
- (void) pause;
- (void) stop;
@end
