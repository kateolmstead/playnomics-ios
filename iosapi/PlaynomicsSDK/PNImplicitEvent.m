//
//  PNImplicitEvent.m
//  iosapi
//
//  Created by Jared Jenkins on 8/28/13.
//
//

#import "PNImplicitEvent.h"


@implementation PNImplicitEvent

- (id) initWithSessionInfo:(PNGameSessionInfo *)sessionInfo instanceId:(PNGeneratedHexId *)instanceId {
    return [super initWithSessionInfo: sessionInfo instanceId: instanceId];
}

- (NSString *) sessionKey {
    return PNEventParameterImplicitSessionId;
}

@end
