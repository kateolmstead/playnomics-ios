//  Playnomics PlayRM SDK
//  PlaynomicsSession.h
//  Copyright (c) 2012 Playnomics. All rights reserved.
//  Please see http://integration.playnomics.com for instructions.
//  Please contact support@playnomics.com for assistance.

#import <UIKit/UIKit.h>
#import "Playnomics.h"
#import "PNGeneratedHexId.h"
#import "PNCache.h"

typedef enum {
    PNSessionStateUnkown,
    PNSessionStateStarted,
    PNSessionStatePaused,
    PNSessionStateStopped
} PNSessionState;


@interface PNSession : NSObject

@property (nonatomic, assign) bool testMode;
@property (nonatomic, copy) NSString *overrideEventsUrl;
@property (nonatomic, copy) NSString *overrideMessagingUrl;

@property (nonatomic, readonly) NSString *sdkVersion;

@property (nonatomic, assign) signed long long applicationId;
@property (nonatomic, copy) NSString *userId;

@property (nonatomic, readonly) NSString *cookieId;
@property (nonatomic, readonly) PNGeneratedHexId *sessionId;
@property (nonatomic, readonly) PNGeneratedHexId *instanceId;
@property (nonatomic, readonly) PNSessionState state;

+ (PNSession*) sharedInstance;

- (NSString *) getMessagingUrl;
- (NSString *) getEventsUrl;

//Application Lifecycle
- (void) start;
- (void) pause;
- (void) resume;
- (void) stop;
//Explicit Events
- (void) milestone: (PNMilestoneType) milestoneType;
- (void) transactionWithUSDPrice: (NSNumber *) priceInUSD quantity: (NSInteger) quantity;
- (void) pingUrlForCallback:(NSString *) url;
//push notifications
- (void) enablePushNotificationsWithToken: (NSData *) deviceToken;
- (void) pushNotificationsWithPayload: (NSDictionary *) payload;
//UI Events/Users/jaredjenkins/Projects/mobile/playnomics-ios/iosapi/iosapi/PNSession.m
- (void) onUIEventReceived: (UIEvent *) event;
//Messaging
- (void) preloadFramesWithIDs: (NSSet *) frameIDs;
- (void) showFrameWithID:(NSString *) frameID;
- (void) showFrameWithID:(NSString *) frameID delegate:(id<PlaynomicsFrameDelegate>) delegate;
- (void) showFrameWithID:(NSString *) frameID delegate:(id<PlaynomicsFrameDelegate>) delegate withInSeconds: (int) timeout;
- (void) hideFrameWithID:(NSString *) frameID;
@end

