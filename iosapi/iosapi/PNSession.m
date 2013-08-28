//
//  PlaynomicsSession.m
//  iosapi
//
//  Created by Douglas Kadlecek on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <libkern/OSAtomic.h>

#import "PNSession.h"
#import "PNRandomGenerator.h"
#import "PNEventSender.h"
#import "PlaynomicsCallback.h"
#import "PNBasicEvent.h"
#import "PNUserInfoEvent.h"
#import "PNTransactionEvent.h"
#import "PNMilestoneEvent.h"
#import "PNAPSNotificationEvent.h"
#import "PNErrorEvent.h"
#import "PNDeviceInfo.h"
#import "PlaynomicsMessaging.h"

@implementation PNSession {
@private
    int _collectMode;
    int _sequence;
    
    NSTimer* _eventTimer;
    NSMutableArray* _playnomicsEventList;
    NSString *_instanceId;
    NSString* _testEventsUrl;
    NSString* _prodEventsUrl;
    NSString* _testMessagingUrl;
    NSString* _prodMessagingUrl;
    
    NSTimeInterval _sessionStartTime;
	NSTimeInterval _pauseTime;
    
    PlaynomicsCallback* _callback;
    PNEventSender* _eventSender;
    PlaynomicsMessaging* _messaging;
    
    int _timeZoneOffset;
	
    volatile NSInteger *_clicks;
    volatile NSInteger *_totalClicks;
    
    volatile NSInteger *_keys;
    volatile NSInteger *_totalKeys;
    
    PNDeviceInfo* _deviceInfo;
    
    NSMutableArray* _observers;
    
    NSMutableDictionary *_framesById;
    
    BOOL _infoUpdate;
}

@synthesize applicationId=_applicationId;
@synthesize userId=_userId;
@synthesize cookieId=_cookieId;
@synthesize sessionId=_sessionId;
@synthesize state=_state;

@synthesize cache=_cache;

@synthesize testMode=_testMode;
@synthesize overrideEventsUrl=_overrideEventsUrl;
@synthesize overrideMessagingUrl=_overrideMessagingUrl;

@synthesize sdkVersion=_sdkVersion;

//Singleton
+ (PNSession *)sharedInstance{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id) init {
    if ((self = [super init])) {
        _collectMode = PNSettingCollectionMode;
        _sequence = 0;
        
        _playnomicsEventList = [[NSMutableArray alloc] init];
        _eventSender = [[PNEventSender alloc] init];
        
        _testEventsUrl = PNPropertyBaseTestUrl;
        _prodEventsUrl = PNPropertyBaseProdUrl;
        _testMessagingUrl = PNPropertyMessagingTestUrl;
        _prodMessagingUrl = PNPropertyMessagingProdUrl;
        
        _callback = [[PlaynomicsCallback alloc] init];
        
        _sdkVersion = PNPropertyVersion;
        
        _cache = [[PNCache alloc] init];
        [_cache loadDataFromCache];
        
        _deviceInfo = [[PNDeviceInfo alloc] initWithCache:_cache];
        
        _observers = [NSMutableArray new];
        
        _messaging = [[PlaynomicsMessaging alloc] initWithSession: self];
        _framesById = [NSMutableDictionary new];
    }
    return self;
}

- (void) dealloc {
    [_eventSender release];
	[_playnomicsEventList release];
    [_callback release];

    /** Tracking values */
    [_userId release];
	[_cookieId release];
	[_sessionId release];
	[_instanceId release];
    
    [_overrideEventsUrl release];
    [_overrideMessagingUrl release];
    [_sdkVersion release];
    
    [_deviceInfo release];
    [_framesById release];
    [super dealloc];
}

#pragma mark - URLs
-(NSString*) getEventsUrl{
    if(_overrideEventsUrl != nil){
        return _overrideEventsUrl;
    }
    if(_testMode){
        return _testEventsUrl;
    }
    return _prodEventsUrl;
}

-(NSString*) getMessagingUrl{
    if(_overrideMessagingUrl != nil){
        return _overrideMessagingUrl;
    }
    if(_testMode){
        return _testMessagingUrl;
    }
    return _prodMessagingUrl;
}

#pragma mark - Session Control Methods
-(BOOL) assertSessionHasStarted{
    if(_state != PNSessionStateStarted){
        [PNLogger log:PNLogLevelError format: @"PlayRM session could not be started! Can't send data to Playnomics API."];
        return NO;
    }
    return YES;
}

-(void) start {
    @try {
        if (_state == PNSessionStateStarted) {
            return;
        }
        
        if (_state == PNSessionStatePaused) {
        
            // If paused, resume and get out of here
            // this should never really occurr
            [self resume];
            return;
        }
        
        [self startSession];
        [self startEventTimer];
    
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        
        void (^keyPressed)(NSNotification *notif) = ^(NSNotification *notif){
            [self incrementKeysPressed];
        };
        void (^applicationPaused)(NSNotification *notif) = ^(NSNotification *notif){
            [self pause];
        };
        void (^applicationResumed)(NSNotification *notif) = ^(NSNotification *notif){
            [self resume];
        };
        void (^applicationTerminating)(NSNotification *notif) = ^(NSNotification *notif){
            [self stop];
        };
        
        void (^applicationLaunched)(NSNotification *notif) = ^(NSNotification *notif){
            if ([notif userInfo] != nil && [notif.userInfo valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil) {
                NSDictionary *push = [notif.userInfo valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
                [self pushNotificationsWithPayload:push];
            }
        };
        
        [_observers addObject: [center addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:mainQueue usingBlock:keyPressed]];
        [_observers addObject: [center addObserverForName:UITextViewTextDidChangeNotification object:nil queue:mainQueue usingBlock:keyPressed]];
        [_observers addObject: [center addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:mainQueue usingBlock:applicationPaused]];
        [_observers addObject: [center addObserverForName:UIApplicationWillTerminateNotification object:nil queue:mainQueue usingBlock:applicationTerminating]];
        [_observers addObject: [center addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:mainQueue usingBlock:applicationLaunched]];
        [_observers addObject: [center addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:mainQueue usingBlock:applicationResumed]];
        
        // Retrieve stored Event List
        NSArray *storedEvents = (NSArray *) [NSKeyedUnarchiver unarchiveObjectWithFile:PNFileEventArchive];
        if ([storedEvents count] > 0) {
            [_playnomicsEventList addObjectsFromArray:storedEvents];
            
            // Remove archive so as not to pick up bad events when starting up next time.
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:PNFileEventArchive error:nil];
        }
        return;
    }
    @catch (NSException *exception) {
        [PNLogger log:PNLogLevelError exception:exception format: @"Could not start the PlayRM SDK."];
    }
}

- (void) startSession{
    /** Setting Session variables */
    _state = PNSessionStateStarted;
    
    _cookieId = [[_cache getBreadcrumbID] retain];
    
    // Set userId to cookieId if it isn't present
    if (!(_userId && [_userId length] > 0)) {
        _userId = [_cookieId retain];
    }
    
    _collectMode = PNSettingCollectionMode;
    _timeZoneOffset = [[NSTimeZone localTimeZone] secondsFromGMT] / -60;
    _sequence = 1;
    
    _clicks = 0;
    _totalClicks = 0;
    
    _keys = 0;
    _totalKeys = 0;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastUserId = [userDefaults stringForKey:PNUserDefaultsLastUserID];
    NSTimeInterval lastSessionStartTime = [userDefaults doubleForKey:PNUserDefaultsLastSessionStartTime];
    
    PNEventType eventType;
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    // Send an appStart if it has been > 3 min since the last session or a different user
    // otherwise send an appPage
    if ((currentTime - lastSessionStartTime > PNSessionTimeout)
        || ![_userId isEqualToString:lastUserId]) {
        
        _sessionId = [[PNRandomGenerator createRandomHex] retain];
        _instanceId = [_sessionId retain];
        _sessionStartTime = currentTime;
        
        eventType = PNEventAppStart;
        
        [userDefaults setObject:_sessionId forKey:PNUserDefaultsLastSessionID];
        [userDefaults setDouble:_sessionStartTime forKey:PNUserDefaultsLastSessionStartTime];
        [userDefaults setObject:_userId forKey:PNUserDefaultsLastUserID];
        [userDefaults synchronize];
    } else {
        _sessionId = [userDefaults objectForKey:PNUserDefaultsLastSessionID];
        // Always create a new Instance Id
        _instanceId = [[PNRandomGenerator createRandomHex] retain];
        _sessionStartTime = [userDefaults doubleForKey:PNUserDefaultsLastSessionStartTime];
        
        eventType = PNEventAppPage;
    }
    
    /** Send appStart or appPage event */
    PNBasicEvent *ev = [[PNBasicEvent alloc] init: eventType
                                    applicationId:_applicationId
                                           userId:_userId
                                         cookieId:_cookieId
                                internalSessionId:_sessionId
                                       instanceId:_instanceId
                                   timeZoneOffset:_timeZoneOffset];
    
    // Try to send and queue if unsuccessful
    [_eventSender sendEventToServer:ev withEventQueue:_playnomicsEventList];
    [ev release];
    
    if(_infoUpdate){
        [self onDeviceInfoChanged];
    }
}

- (void) onApplicationWillResignActive: (NSNotification *) notification {
    [self pause];
}

- (void) pause {
    @try {
        [PNLogger log:PNLogLevelDebug format:@"Session paused."];
        
        if (_state == PNSessionStatePaused){
            return;
        }
        
        _state = PNSessionStatePaused;
        
        [self stopEventTimer];
        
        PNBasicEvent *ev = [[[PNBasicEvent alloc] init:PNEventAppPause applicationId:_applicationId userId:_userId cookieId:_cookieId internalSessionId:_sessionId instanceId:_instanceId sessionStartTime:_sessionStartTime sequence:_sequence clicks: (int)_clicks totalClicks:(int)_totalClicks keys:(int)_keys totalKeys:(int)_totalKeys collectMode:_collectMode] autorelease];
        
        _pauseTime = [[NSDate date] timeIntervalSince1970];
        
        _sequence += 1;
        
        [ev setSequence:_sequence];
        [ev setSessionStartTime:_sessionStartTime];
        
        // Try to send and queue if unsuccessful
        [_eventSender sendEventToServer:ev withEventQueue:_playnomicsEventList];
    }
    @catch (NSException *exception) {
        [PNLogger log: PNLogLevelError exception: exception format:@"Could not pause the Playnomics Session"];
    }
}

/**
 * Resume
 */
- (void) resume {
    @try {
        [PNLogger log:PNLogLevelDebug format:@"Session resumed."];
        
        if (_state == PNSessionStateStarted) {
            return;
        }
        
        [self startEventTimer];
        
        _state = PNSessionStateStarted;
        
        PNBasicEvent *ev = [[[PNBasicEvent alloc] init:PNEventAppResume applicationId:_applicationId userId:_userId cookieId:_cookieId internalSessionId:_sessionId instanceId:_instanceId sessionStartTime:_sessionStartTime sequence:_sequence clicks:(int)_clicks totalClicks:(int)_totalClicks keys:(int)_keys totalKeys:(int)_totalKeys collectMode:_collectMode] autorelease];
        
        ev.pauseTime = _pauseTime;
        ev.sessionStartTime =  _sessionStartTime;
        ev.sequence = _sequence;
    
        // Try to send and queue if unsuccessful
        [_eventSender sendEventToServer:ev withEventQueue:_playnomicsEventList];
    }
    @catch (NSException *exception) {
        [PNLogger log: PNLogLevelError exception: exception format:@"Could not resume the Playnomics Session"];
    }
}

/**
 * Stop.
 *
 * @return the API Result
 */
- (void) stop {
    @try {
        [PNLogger log:PNLogLevelDebug format:@"Session stopped."];
        if (_state == PNSessionStateStopped) {
            return;
        }
        
        // Currently Session is only stopped when the application quits.
        _state = PNSessionStateStopped;
        [self stopEventTimer];
        
        for(id observer in _observers){
            //remove all observers
            [[NSNotificationCenter defaultCenter] removeObserver: observer];
        }
        // Store Event List
        if (![NSKeyedArchiver archiveRootObject: _playnomicsEventList toFile:PNFileEventArchive]) {
            [PNLogger log: PNLogLevelWarning format: @"Playnomics: Could not save event list"];
        }
    }
    @catch (NSException *exception) {
        [PNLogger log: PNLogLevelError exception: exception];
    }
}

#pragma mark - Timed Event Sending
- (void) startEventTimer {
    @try {
        [self stopEventTimer];
        _eventTimer = [[NSTimer scheduledTimerWithTimeInterval:PNUpdateTimeInterval target:self selector:@selector(consumeQueue) userInfo:nil repeats:YES] retain];
    }
    @catch (NSException *exception) {
        [PNLogger log: PNLogLevelError exception: exception];
    }
}

- (void) stopEventTimer {
    @try {
        if ([_eventTimer isValid]) {
            [_eventTimer invalidate];
        }
        [_eventTimer release];
        _eventTimer = nil;
    }
    @catch (NSException *exception) {
        [PNLogger log: PNLogLevelError exception: exception];
    }
}

- (void) consumeQueue {
    @try {
        if (_state == PNSessionStateStarted) {
            _sequence++;
            
            PNBasicEvent *ev = [[[PNBasicEvent alloc] init:PNEventAppRunning applicationId:_applicationId userId:_userId cookieId:_cookieId internalSessionId:_sessionId instanceId:_instanceId sessionStartTime:_sessionStartTime sequence:_sequence clicks:(int)_clicks totalClicks:(int)_totalClicks keys:(int)_keys totalKeys:(int)_totalKeys collectMode:_collectMode] autorelease];
            [_playnomicsEventList addObject:ev];
            
            // Reset keys/clicks
            [self resetKeysPressed];
            [self resetTouchEvents];
        }
        
        for (PNEvent *ev in _playnomicsEventList) {
            [_eventSender sendEventToServer:ev withEventQueue:_playnomicsEventList];
        }
    }
    @catch (NSException *exception) {
        [PNLogger log:PNLogLevelWarning exception: exception];
    }
}

- (void) sendOrQueueEvent:(PNEvent *)pe {
    if (_state != PNSessionStateStarted) {
        //add the event to our queue if we are here
        if(pe != nil){
            [_playnomicsEventList addObject:pe];
        }
    }
    
    // Try to send and queue if unsuccessful
    [_eventSender sendEventToServer:pe withEventQueue:_playnomicsEventList];
}

#pragma mark - Application Event Handlers
- (void) onUIEventReceived: (UIEvent *) event {
    if (event.type == UIEventTypeTouches) {
        UITouch *touch = [event allTouches].anyObject;
        if (touch.phase == UITouchPhaseBegan) {
            [self incrementTouchEvents];
        }
    }
}

-(void) incrementTouchEvents{
    OSAtomicIncrement32Barrier(_clicks);
    OSAtomicIncrement32Barrier(_totalClicks);
}

-(void) resetTouchEvents{
    OSAtomicAnd32Barrier(0, _clicks);
}

-(void) incrementKeysPressed{
    OSAtomicIncrement32Barrier(_keys);
    OSAtomicIncrement32Barrier(_totalKeys);
}

-(void) resetKeysPressed{
    OSAtomicAnd32Barrier(0, _keys);
}

#pragma mark - Device Identifiers

-(void)onDeviceInfoChanged{
    PNUserInfoEvent *userInfoEvent = [[PNUserInfoEvent alloc] initWithAdvertisingInfo:self.applicationId userId: self.userId cookieId: self.cookieId type:PNUserInfoTypeUpdate limitAdvertising: [PNUtil boolAsString: [_cache getLimitAdvertising]] idfa:[_cache getIdfa] idfv: [_cache getIdfv]];
    
    userInfoEvent.internalSessionId = self.sessionId;
    [self sendOrQueueEvent:userInfoEvent];
    [userInfoEvent autorelease];
}

#pragma mark - Explicit Events

- (void) transactionWithUSDPrice: (NSNumber*) priceInUSD quantity: (NSInteger) quantity  {
    @try {
        if(![self assertSessionHasStarted]){ return; }
        
        int transactionId = arc4random();
        
        NSArray *currencyTypes = [NSArray arrayWithObject: [NSNumber numberWithInt: PNCurrencyUSD]];
        NSArray *currencyValues = [NSArray arrayWithObject: priceInUSD];
        NSArray *currencyCategories = [NSArray arrayWithObject: [NSNumber numberWithInt:PNCurrencyCategoryReal]];
        
        NSString *itemId = @"monetized";
        
        PNTransactionEvent *ev = [[[PNTransactionEvent alloc] init:PNEventTransaction applicationId: self.applicationId userId: self.userId cookieId: self.cookieId transactionId: transactionId itemId: itemId quantity: quantity type: PNTransactionBuyItem otherUserId: nil currencyTypes: currencyTypes currencyValues: currencyValues currencyCategories: currencyCategories] autorelease];
        
        ev.internalSessionId = [[PNSession sharedInstance] sessionId];
        [self sendOrQueueEvent:ev];
    }
    @catch (NSException* exception) {
        [PNLogger log:PNLogLevelWarning exception:exception format: @"Could not send transaction."];
    }
}

- (void) milestone: (PNMilestoneType) milestoneType {
    @try {
        if(![self assertSessionHasStarted]){ return; }
        
        //generate a random number for now
        int milestoneId = arc4random();
        PNMilestoneEvent *ev = [[[PNMilestoneEvent alloc] init:PNEventMilestone applicationId:[self applicationId] userId:[self userId] cookieId:[self cookieId] milestoneId:milestoneId milestoneType:milestoneType] autorelease];
        ev.internalSessionId = [self sessionId];
        [self sendOrQueueEvent:ev];
    }
    @catch (NSException *exception) {
        [PNLogger log:PNLogLevelWarning exception:exception format: @"Could not send milestone."];
    }
}

#pragma mark "Push Notifications"

- (void) enablePushNotificationsWithToken:(NSData*)deviceToken {
    @try {
        
        if(![self assertSessionHasStarted]){ return; }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *oldToken = [userDefaults stringForKey:PNUserDefaultsLastDeviceToken];
    
        NSString *newToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        
        if (![newToken isEqualToString:oldToken]) {
            [userDefaults setObject:newToken forKey:PNUserDefaultsLastDeviceToken];
            [userDefaults synchronize];
            
            PNAPSNotificationEvent *ev = [[PNAPSNotificationEvent alloc] init:PNEventPushNotificationToken
                                                                applicationId:[self applicationId]
                                                                       userId:[self userId]
                                                                     cookieId:[self cookieId]
                                                                  deviceToken:deviceToken];
            ev.internalSessionId = self.sessionId;
            [self sendOrQueueEvent: ev];
        }
    }
    @catch (NSException *exception) {
       [PNLogger log:PNLogLevelWarning exception:exception format: @"Could not send device token."];
    }
}

- (void) pushNotificationsWithPayload:(NSDictionary *)payload {
    @try {
        if(![self assertSessionHasStarted]){
            return;
        }
        
        if ([payload valueForKeyPath:PushResponse_InteractionUrl]!=nil) {
            NSString *lastDeviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:PNUserDefaultsLastDeviceToken];
            
            NSString *callbackurl = [payload valueForKeyPath:PushResponse_InteractionUrl];
            // append required parameters to the interaction tracking url
            NSString *trackedCallback = [callbackurl stringByAppendingFormat:@"&%@=%lld&%@=%@&%@=%@&%@=%@",
                                         PushInteractionUrl_AppIdParam, self.applicationId,
                                         PushInteractionUrl_UserIdParam, self.userId,
                                         PushInteractionUrl_BreadcrumbIdParam, self.cookieId,
                                         PushInteractionUrl_PushTokenParam, lastDeviceToken];
            
            UIApplicationState state = [[UIApplication sharedApplication] applicationState];
            // only append the flag "pushIgnored" if the app is in Active state and either
            // the game developer doesn't pass us the flag "pushIgnored" in the dictionary or they do pass the flag and set it to YES
            if (state == UIApplicationStateActive && !([payload objectForKey:PushInteractionUrl_IgnoredParam] && [[payload objectForKey:PushInteractionUrl_IgnoredParam] isEqual:[NSNumber numberWithBool:NO]])) {
                trackedCallback = [trackedCallback stringByAppendingFormat:@"&%@",PushInteractionUrl_IgnoredParam];
            }
            
            [_callback submitRequestToServer: trackedCallback];
        }
    }
    @catch (NSException *exception) {
        [PNLogger log:PNLogLevelWarning exception:exception format: @"Could not send process push notification data."];
    }   
}

- (void) errorReport:(PNErrorDetail *)errorDetails
{
    @try {
        PNErrorEvent *ev = [[[PNErrorEvent alloc] init:PNEventError applicationId: self.applicationId userId: self.userId cookieId: self.cookieId errorDetails:errorDetails] autorelease];
        
        ev.internalSessionId = [self sessionId];
        [self sendOrQueueEvent:ev];
    }
    @catch (NSException *exception) {
        NSLog(@"error: %@", exception.description);
    }
}




#pragma mark "Messaging"
//all of this code needs to be moved inside of PlaynomicsMessaging
- (void) preloadFramesWithIDs: (NSSet *)frameIDs{
    for(NSString* frameID in frameIDs)
    {
        [self getOrAddFrame:frameID];
    }
}

- (id) getOrAddFrame: (NSString *) frameID{
    PlaynomicsFrame *frame = [_framesById valueForKey:frameID];
    if(!frame){
        frame = [_messaging createFrameWithId: frameID];
        [_framesById setValue:frame forKey:frameID];
    }
    return frame;
}

- (void) showFrameWithID:(NSString *) frameID{
    PlaynomicsFrame *frame = [self getOrAddFrame:frameID];
    [frame start];
};
 
- (void) showFrameWithID:(NSString *) frameID delegate:(id<PNFrameDelegate>) delegate{
    PlaynomicsFrame *frame = [self getOrAddFrame:frameID];
    frame.delegate = delegate;
    [frame start];
};

- (void) showFrameWithID:(NSString *) frameID delegate:(id<PNFrameDelegate>) delegate withInSeconds: (int) timeout{
    PlaynomicsFrame *frame = [self getOrAddFrame:frameID];
    frame.delegate = delegate;
    [frame start];
};

- (void) hideFrameWithID:(NSString *) frameID{
    
};
@end

