//
//  Playnomics.m
//  iosapi
//
//  Created by Jared Jenkins on 8/23/13.
//
//

#import "Playnomics.h"
#import "PlaynomicsSession.h"


@implementation Playnomics
+ (void) overrideMessagingURL: (NSString*) messagingUrl{
    [PlaynomicsSession sharedInstance].overrideMessagingUrl = messagingUrl;
}

+ (void) overrideEventsURL: (NSString*) eventsUrl{
    [PlaynomicsSession sharedInstance].overrideEventsUrl = eventsUrl;
}

+ (BOOL) startWithApplicationId:(signed long long) applicationId{
    PlaynomicsSession *session = [PlaynomicsSession sharedInstance];
    [session start];
    
    return session.state == PNSessionStateStarted;
}

+ (BOOL) startWithApplicationId:(signed long long) applicationId andUserId: (NSString*) userId{
    PlaynomicsSession *session = [PlaynomicsSession sharedInstance];
    session.applicationId = applicationId;
    session.userId = userId;
    [session start];
    return session.state == PNSessionStateStarted;
}

+ (void) onTouchDown: (UIEvent*) event{
    
}

+ (void) milestone: (PNMilestoneType) milestoneType{
    [[PlaynomicsSession sharedInstance] milestone: milestoneType];
}

+ (void) transactionWithUSDPrice: (NSNumber*) priceInUSD quantity: (NSInteger) quantity{
    [[PlaynomicsSession sharedInstance] transactionWithUSDPrice:priceInUSD quantity: quantity];
}

+ (void) enablePushNotificationsWithToken: (NSData*)deviceToken{
    [[PlaynomicsSession sharedInstance] enablePushNotificationsWithToken: deviceToken];
}

+ (void) pushNotificationsWithPayload: (NSDictionary*)payload{
    
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
