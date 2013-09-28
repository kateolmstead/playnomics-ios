//
//  PNAppPage.h
//  iosapi
//
//  Created by Jared Jenkins on 8/28/13.
//
//

#import "PNImplicitEvent.h"

@interface PNEventAppPage : PNImplicitEvent
- (id) initWithSessionInfo: (PNGameSessionInfo *) sessionInfo instanceId: (PNGeneratedHexId *) instanceId;
- (NSString *) baseUrlPath;
@end
