//  Playnomics PlayRM SDK
//  PlaynomicsSession.h
//  Copyright (c) 2012 Playnomics. All rights reserved.
//  Please see http://integration.playnomics.com for instructions.
//  Please contact support@playnomics.com for assistance.

#import <UIKit/UIKit.h>
#import "Playnomics.h"
#import "PNGeneratedHexId.h"
#import "PNErrorDetail.h"
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
@property (nonatomic, readonly) PNSessionState state;

@property (nonatomic, readonly) PNCache *cache;

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
//push notifications
- (void) enablePushNotificationsWithToken: (NSData *)deviceToken;
- (void) pushNotificationsWithPayload: (NSDictionary *)payload;
//UI Events
- (void) onUIEventReceived: (UIEvent *) event;
//Report errors
- (void) errorReport:(PNErrorDetail*)errorDetails;
//Messaging
- (void) preloadFramesWithIDs: (NSSet *) frameIDs;
- (void) showFrameWithID:(NSString *) frameID;
- (void) showFrameWithID:(NSString *) frameID delegate:(id<PNFrameDelegate>) delegate;
- (void) showFrameWithID:(NSString *) frameID delegate:(id<PNFrameDelegate>) delegate withInSeconds: (int) timeout;
- (void) hideFrameWithID:(NSString *) frameID;
@end

