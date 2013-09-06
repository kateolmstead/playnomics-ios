//
// Created by jmistral on 10/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "Playnomics.h"
#import "PNFrame.h"

@interface PNMessaging : NSObject
// Initialize a frame using data retrieved from the Playnomics Messaging Server.  The returned instance is
// AUTORELEASED and must be retained by the clients.
- (id) initWithSession: (PNSession *) session;
- (PNFrame *)createFrameWithId:(NSString *)frameId;
- (PNFrame *)createFrameWithId:(NSString *)frameId frameDelegate: (id<PlaynomicsFrameDelegate>)frameDelegate;
@end
