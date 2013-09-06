//
// Created by jmistral on 10/11/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "Playnomics.h"
#import "PlaynomicsFrame.h"

@interface PlaynomicsMessaging : NSObject
// Initialize a frame using data retrieved from the Playnomics Messaging Server.  The returned instance is
// AUTORELEASED and must be retained by the clients.
- (id) initWithSession: (PNSession *) session;
- (PlaynomicsFrame *)createFrameWithId:(NSString *)frameId;
- (PlaynomicsFrame *)createFrameWithId:(NSString *)frameId frameDelegate: (id<PNFrameDelegate>)frameDelegate;
@end
