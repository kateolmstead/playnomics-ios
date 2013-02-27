//
//  PNAPSNotificationEvent.m
//  PlaynomicsSample
//
//  Created by Eric McConkie on 1/15/13.
//  Copyright (c) 2013 Grio. All rights reserved.
//

#import "PNAPSNotificationEvent.h"
#import "PlaynomicsCallback.h"


#define kPushCallbackUrl         @"t"

@interface PNAPSNotificationEvent()
@property (nonatomic ) PNAPSNotificationEventType pushEventType;
@property (nonatomic, retain) NSData *deviceToken;
@property (nonatomic, retain) NSDictionary *payload;
@property (nonatomic,retain) PlaynomicsCallback *callbackUtil;
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

- (id)init:(PNEventType)eventType applicationId:(long long)applicationId userId:(NSString *)userId cookieId:(NSString *)cookieId payload:(NSDictionary*)payload
{
    self = [super init:eventType applicationId:applicationId userId:userId cookieId:cookieId];
    _pushEventType = PNAPSNotificationEventTypeNotificationReceived;
    if (self) {
        [self setPayload:payload];
        self.callbackUtil = [[PlaynomicsCallback alloc] init];

        
    }
    return self;
}

- (NSString *) toQueryString {

    NSString *adeviceToken = [[_deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    adeviceToken = [adeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString * queryString = nil;
    switch (self.pushEventType) {
        case PNAPSNotificationEventTypeDeviceToken:
        {
            queryString = [[super toQueryString] stringByAppendingFormat:@"&pushTok=%@&jsh=%@",
                           adeviceToken,
                           [self internalSessionId]];
        }
            break;
            
        //decode the pushnotiicaiton and report back
        //not sure if we need to use user info string?
        case PNAPSNotificationEventTypeNotificationReceived:
        {
            
            //this is all fluff
            NSDictionary *push = self.payload;
            NSString *callback = [push valueForKeyPath:kPushCallbackUrl];
            [self.callbackUtil submitAdImpressionToServer:callback];
            
        }
            break;
        default:
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
