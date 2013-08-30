//
//  PNAppPage.m
//  iosapi
//
//  Created by Jared Jenkins on 8/28/13.
//
//

#import "PNEventAppPage.h"

@implementation PNEventAppPage

- (id) initWithSessionInfo: (PNGameSessionInfo *) sessionInfo instanceId: (PNGeneratedHexId *) instanceId {
    if((self = [super initWithSessionInfo: sessionInfo instanceId: instanceId])){
        [self appendParameter:[NSNumber numberWithInt: [PNUtil timezoneOffet]] forKey: PNEventParameterTimezoneOffset];
    }
    return self;
}

- (NSString *) baseUrlPath{
    return @"appPage";
}

@end
