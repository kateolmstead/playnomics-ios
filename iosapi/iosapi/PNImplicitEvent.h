//
//  PNImplicitEvent.h
//  iosapi
//
//  Created by Jared Jenkins on 8/28/13.
//
//

#import <Foundation/Foundation.h>
#import "PNEvent.h"

@interface PNImplicitEvent : PNEvent
- (id) initWithSessionInfo: (PNGameSessionInfo *) sessionInfo instanceId:(PNGeneratedHexId *)instanceId;
- (NSString *) sessionKey;
@end
