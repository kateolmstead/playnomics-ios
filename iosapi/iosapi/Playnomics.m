//
//  Playnomics.m
//  iosapi
//
//  Created by Jared Jenkins on 8/23/13.
//
//

#import "Playnomics.h"
#import "PNSession.h"


@implementation Playnomics
+ (void) overrideMessagingURL: (NSString*) messagingUrl{
    [PNSession sharedInstance].overrideMessagingUrl = messagingUrl;
}

+ (void) overrideEventsURL: (NSString*) eventsUrl{
    [PNSession sharedInstance].overrideEventsUrl = eventsUrl;
}

+ (BOOL) startWithApplicationId:(signed long long) applicationId{
    PNSession *session = [PNSession sharedInstance];
    [session start];
    
    return session.state == PNSessionStateStarted;
}

+ (BOOL) startWithApplicationId:(signed long long) applicationId andUserId: (NSString*) userId{
    PNSession *session = [PNSession sharedInstance];
    session.applicationId = applicationId;
    session.userId = userId;
    [session start];
    return session.state == PNSessionStateStarted;
}

+ (void) onUIEventReceived:(UIEvent *)event{
    [[PNSession sharedInstance] onUIEventReceived: event];
}

+ (void) milestone: (PNMilestoneType) milestoneType{
    [[PNSession sharedInstance] milestone: milestoneType];
}

+ (void) transactionWithUSDPrice: (NSNumber*) priceInUSD quantity: (NSInteger) quantity{
    [[PNSession sharedInstance] transactionWithUSDPrice:priceInUSD quantity: quantity];
}

+ (void) enablePushNotificationsWithToken: (NSData*)deviceToken{
    [[PNSession sharedInstance] enablePushNotificationsWithToken: deviceToken];
}

+ (void) pushNotificationsWithPayload: (NSDictionary*)payload{
    [[PNSession sharedInstance] pushNotificationsWithPayload: payload];
}

+ (void) preloadFramesWithIds: (NSString *)firstFrameId, ...{
    
}

+ (void) showFrameWithId:(NSString*) frameId{
    
}

+ (void) showFrameWithId:(NSString*) frameId delegate:(id<PNFrameDelegate>) delegate{
    
}

+ (void) showFrameWithId:(NSString*) frameId delegate:(id<PNFrameDelegate>) delegate withInSeconds: (int) timeout{
    
}

+ (void) hideFrameWithId:(NSString*) frameId{
    
}

@end
