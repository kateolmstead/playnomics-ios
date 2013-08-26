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
+ (void) overrideMessagingURL: (NSString *) messagingUrl{
    [PNSession sharedInstance].overrideMessagingUrl = messagingUrl;
}

+ (void) overrideEventsURL: (NSString *) eventsUrl{
    [PNSession sharedInstance].overrideEventsUrl = eventsUrl;
}

+ (BOOL) startWithApplicationId:(signed long long) applicationId{
    PNSession *session = [PNSession sharedInstance];
    [session start];
    
    return session.state == PNSessionStateStarted;
}

+ (BOOL) startWithApplicationId:(signed long long) applicationId andUserId: (NSString *) userId{
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

+ (void) transactionWithUSDPrice: (NSNumber *) priceInUSD quantity: (NSInteger) quantity{
    [[PNSession sharedInstance] transactionWithUSDPrice:priceInUSD quantity: quantity];
}

+ (void) enablePushNotificationsWithToken: (NSData *)deviceToken{
    [[PNSession sharedInstance] enablePushNotificationsWithToken: deviceToken];
}

+ (void) pushNotificationsWithPayload: (NSDictionary *)payload{
    [[PNSession sharedInstance] pushNotificationsWithPayload: payload];
}

+ (void) preloadFramesWithIDs: (NSString *)firstFrameID, ...{
    NSMutableSet *frameIDs = [NSMutableSet new];
    va_list args;
    va_start(args, firstFrameID);
    [frameIDs addObject:firstFrameID];
   
    NSString* frameID;
    while( (frameID = va_arg(args, NSString *)) )
    {
        [frameIDs addObject: frameID];
    }
    va_end(args);
    
    [[PNSession sharedInstance] preloadFramesWithIDs: frameIDs];
    [frameIDs autorelease];
}

+ (void) showFrameWithID:(NSString *) frameID{
    [[PNSession sharedInstance] showFrameWithID: frameID];
}

+ (void) showFrameWithID:(NSString *) frameID delegate:(id<PNFrameDelegate>) delegate{
    [[PNSession sharedInstance] showFrameWithID: frameID delegate:delegate];
}

+ (void) showFrameWithID:(NSString *) frameID delegate:(id<PNFrameDelegate>) delegate withInSeconds: (int) timeout{
    [[PNSession sharedInstance] showFrameWithID: frameID delegate:delegate withInSeconds:timeout];
}

+ (void) hideFrameWithID:(NSString *) frameID{
    [[PNSession sharedInstance] hideFrameWithID: frameID];
}

@end
