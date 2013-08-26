//
//  PNAPSNotificationEvent.m
//  PlaynomicsSample
//
//  Created by Eric McConkie on 1/15/13.
//  Copyright (c) 2013 Grio. All rights reserved.
//

#import "PNAPSNotificationEvent.h"

@interface PNAPSNotificationEvent()
@property (nonatomic ) PNAPSNotificationEventType pushEventType;
@property (nonatomic, retain) NSData *deviceToken;
@property (nonatomic, retain) NSDictionary *payload;

@end

@implementation PNAPSNotificationEvent
@synthesize deviceToken = _deviceToken;
@synthesize pushEventType = _pushEventType;
@synthesize payload  = _payload;

- (id)init:(PNEventType)eventType applicationId:(long long)applicationId userId:(NSString *)userId cookieId:(NSString *)cookieId deviceToken:(NSData*)deviceToken
{
    self = [super init:eventType applicationId:applicationId userId:userId cookieId:cookieId];
    _pushEventType = PNAPSNotificationEventTypeDeviceToken;
    if (self) {
        [self setDeviceToken:deviceToken];

    }
    return self;
}



- (NSString *) toQueryString {

    NSString *adeviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:PNUserDefaultsLastDeviceToken];
    NSString * queryString = nil;
    switch (self.pushEventType) {
        case PNAPSNotificationEventTypeDeviceToken:
        {
            queryString = [[super toQueryString] stringByAppendingFormat:@"&pushTok=%@&jsh=%@",
                           adeviceToken,
                           [self internalSessionId]];
        }
            break;
        
    }
    return queryString;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_deviceToken forKey:@"PNAPSNotificationEvent._deviceToken"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
    
        _deviceToken = (NSData *) [[decoder decodeObjectForKey:@"PNAPSNotificationEvent._deviceToken"] retain];
    }
    return self;
}

@end
