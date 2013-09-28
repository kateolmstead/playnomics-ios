//
//  PNExplicitEvent.m
//  iosapi
//
//  Created by Jared Jenkins on 8/28/13.
//
//

#import "PNExplicitEvent.h"

@implementation PNExplicitEvent

- (id) initWithSessionInfo:(PNGameSessionInfo *)info{
    return [super initWithSessionInfo:info];
}

- (NSString *) sessionKey {
    return PNEventParameterExplicitSessionId;
}

@end
