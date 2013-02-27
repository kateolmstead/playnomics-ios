//
//  PNAPSNotificationEvent.h
//  PlaynomicsSample
//
//  Created by Eric McConkie on 1/15/13.
//  Copyright (c) 2013 Grio. All rights reserved.
//

#import "PNEvent.h"

typedef enum
{
    PNAPSNotificationEventTypeDeviceToken,

}PNAPSNotificationEventType;

@interface PNAPSNotificationEvent : PNEvent
- (id)init:(PNEventType)eventType applicationId:(long long)applicationId userId:(NSString *)userId cookieId:(NSString *)cookieId deviceToken:(NSData*)deviceToken;

@end
