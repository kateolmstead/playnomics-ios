//
//  PNEventAppStart.h
//  iosapi
//
//  Created by Jared Jenkins on 8/28/13.
//
//

#import "PNImplicitEvent.h"

@interface PNEventAppStart : PNImplicitEvent

- (id) initWithSessionInfo: (PNGameSessionInfo *) sessionInfo instanceId: (PNGeneratedHexId *) instanceId;

- (NSString *) baseUrlPath;

@end
