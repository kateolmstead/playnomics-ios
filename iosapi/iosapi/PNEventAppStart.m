//
//  PNEventAppStart.m
//  iosapi
//
//  Created by Jared Jenkins on 8/28/13.
//
//

#import "PNEventAppStart.h"

@implementation PNEventAppStart

- (id) initWithSessionInfo: (PNGameSessionInfo *) sessionInfo instanceId: (PNGeneratedHexId *) instanceId {
    if((self = [super initWithSessionInfo: sessionInfo instanceId: instanceId])){
        [self appendParameter: [NSNumber numberWithInt: [PNUtil timezoneOffet]] forKey: PNEventParameterTimezoneOffset];
    }
}

- (NSString *) baseUrlPath{
    return @"appStart";
}

@end
