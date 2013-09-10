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

+(void) setLoggingLevel:(PNLoggingLevel)level{
    [PNLogger setLoggingLevel: level];
}

+ (void) overrideMessagingURL: (NSString *) messagingUrl{
    [PNSession sharedInstance].overrideMessagingUrl = messagingUrl;
}

+ (void) overrideEventsURL: (NSString *) eventsUrl{
    [PNSession sharedInstance].overrideEventsUrl = eventsUrl;
}

+(void) setTestMode : (BOOL) testMode{
    [PNSession sharedInstance].testMode = testMode;
}

+ (BOOL) startWithApplicationId:(unsigned long long) applicationId{
    PNSession *session = [PNSession sharedInstance];
    session.applicationId = applicationId;
    [session start];
    return session.state == PNSessionStateStarted;
}

+ (BOOL) startWithApplicationId:(unsigned long long) applicationId
                      andUserId: (NSString *) userId{
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

+ (void) transactionWithUSDPrice: (NSNumber *) priceInUSD
                        quantity: (NSInteger) quantity{
    [[PNSession sharedInstance] transactionWithUSDPrice:priceInUSD quantity: quantity];
}

+ (void) enablePushNotificationsWithToken: (NSData *)deviceToken{
    [[PNSession sharedInstance] enablePushNotificationsWithToken: deviceToken];
}

+ (void) pushNotificationsWithPayload: (NSDictionary *)payload{
    [[PNSession sharedInstance] pushNotificationsWithPayload: payload];
}

+ (void) preloadFramesWithIds: (NSString *)firstFrameId, ...{
    NSMutableSet *frameIds = [NSMutableSet new];
    va_list args;
    va_start(args, firstFrameId);
    [frameIds addObject:firstFrameId];
   
    NSString* frameId;
    while( (frameId = va_arg(args, NSString *)) )
    {
        [frameIds addObject: frameId];
    }
    va_end(args);
    
    [[PNSession sharedInstance] preloadFramesWithIds: frameIds];
    [frameIds autorelease];
}

+ (void) showFrameWithId:(NSString *) frameId{
    [[PNSession sharedInstance] showFrameWithId: frameId];
}

+(void) showFrameWithId:(NSString *)frameId
                 inView:(UIView *)parentView{
    [[PNSession sharedInstance] showFrameWithId: frameId inView: parentView];
}

+ (void) showFrameWithId:(NSString *) frameId
                delegate:(id<PlaynomicsFrameDelegate>) delegate{
    [[PNSession sharedInstance] showFrameWithId: frameId delegate:delegate];
}

+ (void) showFrameWithId:(NSString *) frameID
                delegate:(id<PlaynomicsFrameDelegate>) delegate
                  inView:(UIView *)parentView{
    [[PNSession sharedInstance] showFrameWithId: frameID delegate:delegate inView:parentView];
}

+ (void) hideFrameWithId:(NSString *) frameId{
    [[PNSession sharedInstance] hideFrameWithID: frameId];
}

@end
