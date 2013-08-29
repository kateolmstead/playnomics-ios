//
//  PlaynomicsSession.m
//  iosapi
//
//  Created by Douglas Kadlecek on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <libkern/OSAtomic.h>

#import "PNSession.h"
#import "PNEventApiClient.h"
#import "PlaynomicsCallback.h"
#import "PNUserInfoEvent.h"
#import "PNTransactionEvent.h"
#import "PNMilestoneEvent.h"
#import "PNDeviceManager.h"
#import "PlaynomicsMessaging.h"

//events
#import "PNEventAppPage.h"
#import "PNEventAppStart.h"
#import "PNEventAppPause.h"
#import "PNEventAppResume.h"
#import "PNEventAppRunning.h"
#import "PNEvent.h"
#import "PNTransactionEvent.h"
#import "PNMilestoneEvent.h"
#import "PNUserInfoEvent.h"

@implementation PNSession {
@private
    int _collectMode;
    int _sequence;
    
    NSTimer* _eventTimer;
    PNGeneratedHexId *_instanceId;
    NSString* _testEventsUrl;
    NSString* _prodEventsUrl;
    NSString* _testMessagingUrl;
    NSString* _prodMessagingUrl;
    
    NSTimeInterval _sessionStartTime;
	NSTimeInterval _pauseTime;
    
    PlaynomicsCallback* _callback;
    PNEventApiClient* _apiClient;
    PlaynomicsMessaging* _messaging;
    
    volatile NSInteger *_clicks;
    volatile NSInteger *_totalClicks;
    
    volatile NSInteger *_keys;
    volatile NSInteger *_totalKeys;
    
    PNDeviceManager* _deviceInfo;
    
    NSMutableArray* _observers;
    
    NSMutableDictionary *_framesById;

    NSObject *_syncLock;
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
        
        _apiClient = [[PNEventApiClient alloc] init];
        
        _testEventsUrl = PNPropertyBaseTestUrl;
        _prodEventsUrl = PNPropertyBaseProdUrl;
        _testMessagingUrl = PNPropertyMessagingTestUrl;
        _prodMessagingUrl = PNPropertyMessagingProdUrl;
        
        _callback = [[PlaynomicsCallback alloc] init];
        
        _sdkVersion = PNPropertyVersion;
        
        _cache = [[PNCache alloc] init];
        _deviceInfo = [[PNDeviceManager alloc] initWithCache:_cache];
        
        _observers = [NSMutableArray new];
        
        _messaging = [[PlaynomicsMessaging alloc] initWithSession: self];
        _framesById = [NSMutableDictionary new];
        
        _syncLock = [[NSObject alloc] init];
    }
    return self;
}

- (void) dealloc {
    [_apiClient release];
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
    
    [_syncLock release];
    
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
-(PNGameSessionInfo *) getGameSessionInfo{
    
    PNGameSessionInfo * info =  [[PNGameSessionInfo alloc] initWithApplicationId:self.applicationId userId:self.userId breadcrumbId:[_cache getBreadcrumbID] sessionId: self.sessionId];
                                 
    [info autorelease];
    return info;
}

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
            
            for(int i = 0; i < [storedEvents count]; i ++){
                NSString* eventUrl = [storedEvents objectAtIndex:i];
                [_apiClient enqueueEventUrl: eventUrl];
            }
            
            // Remove archive so as not to pick up bad events when starting up next time.
            [[NSFileManager defaultManager] removeItemAtPath:PNFileEventArchive error:nil];
        }
        return;
    }
    @catch (NSException *exception) {
        [PNLogger log:PNLogLevelError exception:exception format: @"Could not start the PlayRM SDK."];
    }
}

- (void) startSession{
    /** Setting Session variables */
    [_cache loadDataFromCache];
    
    _state = PNSessionStateStarted;
    
    _cookieId = [[_cache getBreadcrumbID] retain];
    
    // Set userId to cookieId if it isn't present
    if (!(_userId && [_userId length] > 0)) {
        _userId = [_cookieId retain];
    }
    
    _collectMode = PNSettingCollectionMode;
    _sequence = 1;
    
    _clicks = 0;
    _totalClicks = 0;
    
    _keys = 0;
    _totalKeys = 0;
    
    NSString *lastUserId = [_cache getLastUserId];
    NSTimeInterval lastSessionStartTime = [_cache getLastEventTime];
    
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    
    //per our events specification, the sessionStart is always when the session start call is made,
    //regardless of whether is an appPage or appStart
   
    
    bool sessionLapsed = (currentTime - lastSessionStartTime > PNSessionTimeout) || ![_userId isEqualToString:lastUserId];
    
    // Send an appStart if it has been > 3 min since the last session or a different user
    // otherwise send an appPage
    if (sessionLapsed) {
        
        _sessionId = [[PNGeneratedHexId alloc] initAndGenerateValue];
        _instanceId = [_sessionId retain];
        [_cache updateLastSessionId: _sessionId];
        [_cache updateLastUserId: _userId];
        [_cache updateLastEventTimeToNow];
    } else {
        _sessionId = [_cache getLastSessionId];
        // Always create a new Instance Id
        _instanceId = [[PNGeneratedHexId alloc] initAndGenerateValue];
    }
    
    /** Send appStart or appPage event */
    PNEvent *ev = sessionLapsed ? [[PNEventAppStart alloc] initWithSessionInfo: [self getGameSessionInfo] instanceId: _instanceId]
            : [[PNEventAppPage alloc] initWithSessionInfo: [self getGameSessionInfo] instanceId: _instanceId];
    [ev autorelease];
    _sessionStartTime = ev.eventTime;
    // Try to send and queue if unsuccessful
    [_apiClient enqueueEvent:ev];

    if([_deviceInfo syncDeviceSettingsWithCache]){
        [self onDeviceInfoChanged];
    }
    
    [_cache writeDataToCache];
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
        
        
        PNEventAppPause *ev = [[PNEventAppPause alloc] initWithSessionInfo:[self getGameSessionInfo] instanceId:_instanceId sessionStartTime:_sessionStartTime sequenceNumber:_sequence touches:*_clicks totalTouches:*_totalClicks];
        [ev autorelease];
        _pauseTime = ev.eventTime;
        _sequence += 1;
        
        // Try to send and queue if unsuccessful
        
        [_apiClient pause];
        [_apiClient enqueueEvent:ev];
        
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
        
        PNEventAppResume *ev  = [[PNEventAppResume alloc] initWithSessionInfo: [self getGameSessionInfo] instanceId: _instanceId sessionPauseTime:_pauseTime sessionStartTime:_sessionStartTime sequenceNumber:_sequence];
        [ev autorelease];
        [_apiClient enqueueEvent: ev];
        [_apiClient start];
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
        
        [_cache writeDataToCache];
        
        [_apiClient stop];
        NSSet *unprocessedEvents = [_apiClient getAllUnprocessedUrls];
        // Store Event List
        if (![NSKeyedArchiver archiveRootObject: unprocessedEvents toFile:PNFileEventArchive]) {
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
            
            PNEventAppRunning *ev = [[PNEventAppRunning alloc] initWithSessionInfo: [self getGameSessionInfo] instanceId: _instanceId sessionStartTime: _sessionStartTime sequenceNumber: _sequence touches:*_clicks totalTouches: *_totalClicks];
            [ev autorelease];
         
            [_apiClient enqueueEvent:ev];
            
            // Reset keys/clicks
            [self resetTouchEvents];
        }
    }
    @catch (NSException *exception) {
        [PNLogger log:PNLogLevelWarning exception: exception];
    }
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
    @synchronized(_syncLock){
        _clicks = 0;
    }
}

-(void) incrementKeysPressed{
    OSAtomicIncrement32Barrier(_keys);
    OSAtomicIncrement32Barrier(_totalKeys);
}

-(void) resetKeysPressed{
    @synchronized(_syncLock){
        _keys = 0;
    }
}

#pragma mark - Device Identifiers

-(void)onDeviceInfoChanged{
    PNUserInfoEvent *userInfo = [[PNUserInfoEvent alloc] initWithSessionInfo:[self getGameSessionInfo] limitAdvertising:[_cache getLimitAdvertising] idfa:[_cache getIdfa] idfv: [_cache getIdfv]];
    [_apiClient enqueueEvent:userInfo];
    [userInfo autorelease];
}

#pragma mark - Explicit Events

- (void) transactionWithUSDPrice: (NSNumber *) priceInUSD quantity: (NSInteger) quantity  {
    @try {
        if(![self assertSessionHasStarted]){ return; }
        
        NSArray *currencyTypes = [NSArray arrayWithObject: [NSNumber numberWithInt: PNCurrencyUSD]];
        NSArray *currencyValues = [NSArray arrayWithObject: priceInUSD];
        NSArray *currencyCategories = [NSArray arrayWithObject: [NSNumber numberWithInt:PNCurrencyCategoryReal]];
        
        NSString *itemId = @"monetized";
        
        PNTransactionEvent *ev = [[PNTransactionEvent alloc] initWithSessionInfo:[self getGameSessionInfo] itemId:itemId quantity:quantity type:PNTransactionBuyItem currencyTypes:currencyTypes currencyValues:currencyValues currencyCategories:currencyCategories];
        [ev autorelease];
        [_apiClient enqueueEvent:ev];
    }
    @catch (NSException* exception) {
        [PNLogger log:PNLogLevelWarning exception:exception format: @"Could not send transaction."];
    }
}

- (void) milestone: (PNMilestoneType) milestoneType {
    @try {
        if(![self assertSessionHasStarted]){ return; }
        
        PNMilestoneEvent *ev = [[PNMilestoneEvent alloc] initWithSessionInfo:[self getGameSessionInfo] milestoneType:milestoneType];
        [ev autorelease];
        [_apiClient enqueueEvent:ev];
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
            
            PNUserInfoEvent *ev = [[PNUserInfoEvent alloc] initWithSessionInfo:[self getGameSessionInfo] pushToken: newToken];
            [ev autorelease];
            [_apiClient enqueueEvent: ev];
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

