//
//  PlaynomicsSession.m
//  iosapi
//
//  Created by Douglas Kadlecek on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaynomicsSession.h"

#import "PLConfig.h"
#import "PLConstants.h"

#import "RandomGenerator.h"

#import "EventSender.h"

#import "BasicEvent.h"
#import "UserInfoEvent.h"
#import "SocialEvent.h"
#import "TransactionEvent.h"
#import "GameEvent.h"

#import "PlaynomicsSession+Exposed.h"

@interface PlaynomicsSession () {    
    PLSessionState _sessionState;

    NSTimer *_eventTimer;
    EventSender *_eventSender;
    NSMutableArray *_playnomicsEventList;
    
    
    /** Tracking values */
    int _collectMode;
	int _sequence;
    long _applicationId;
    NSString *_userId;
	NSString *_cookieId; // TODO: Doc says this should be a 64 bit number
	NSString *_sessionId;
	NSString *_instanceId;
	
    NSTimeInterval _sessionStartTime;
	NSTimeInterval _pauseTime;
    
	int _timeZoneOffset;
	int _clicks;
	int _totalClicks;
	int _keys;
	int _totalKeys;
}
@property (atomic, readonly)    NSMutableArray *   playnomicsEventList;
@property (nonatomic, readonly) long            applicationId;
@property (nonatomic, readonly) NSString *      userId;


- (PLAPIResult) startWithApplicationId:(long) applicationId;
- (PLAPIResult) startWithApplicationId:(long) applicationId userId: (NSString *) userId;
- (PLAPIResult) sendOrQueueEvent: (PlaynomicsEvent *) pe;

- (PLAPIResult) stop;
- (void) pause;
- (void) resume;

- (void) consumeQueue;
@end

@implementation PlaynomicsSession
@synthesize playnomicsEventList=_playnomicsEventList;
@synthesize applicationId=_applicationId;
@synthesize userId=_userId;

//Singleton
+ (PlaynomicsSession *)sharedInstance{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

+ (PLAPIResult) startWithApplicationId:(long) applicationId userId: (NSString *) userId {
    return [[PlaynomicsSession sharedInstance] startWithApplicationId:applicationId userId:userId];
}

+ (PLAPIResult) startWithApplicationId:(long) applicationId {
    return [[PlaynomicsSession sharedInstance] startWithApplicationId:applicationId];
}

+ (PLAPIResult) stop {
    return [[PlaynomicsSession sharedInstance] stop];
}

+ (void) pause {
    [[PlaynomicsSession sharedInstance] pause];
}

- (id) init {
    if ((self = [super init])) {
        _collectMode = PLSettingCollectionMode;
        _sequence = 0;
        _userId = @"";
        _playnomicsEventList = [[NSMutableArray alloc] init];
        _eventSender = [[EventSender alloc] init];
    }
    return self;
}

- (void) dealloc {
    [_eventSender release];
	[self.playnomicsEventList release];
    
    /** Tracking values */
    [_userId release];
	[_cookieId release];
	[_sessionId release];
	[_instanceId release];
    
    [super dealloc];
}

#pragma mark - Session Control Methods
- (PLAPIResult) startWithApplicationId:(long) applicationId userId: (NSString *) userId {
    _userId = [userId retain];
    return [self startWithApplicationId:applicationId];
}

- (PLAPIResult) startWithApplicationId:(long) applicationId {
    if (_sessionState == PLSessionStateStarted)
        return PLAPIResultAlreadyStarted;
    
    // If paused, resume and get out of here
    if (_sessionState == PLSessionStatePaused) {
        [self resume];
        return PLAPIResultSessionResumed;
    }
    
    PLAPIResult result;
    
    _sessionState = PLSessionStateStarted;
    
    _applicationId = applicationId;
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver: self selector: @selector(onKeyPressed:) name: UITextFieldTextDidChangeNotification object: nil];
    [defaultCenter addObserver: self selector: @selector(onKeyPressed:) name: UITextViewTextDidChangeNotification object: nil];
    [defaultCenter addObserver: self selector: @selector(onGestureStateChanged:) name: @"_UIApplicationSystemGestureStateChangedNotification" object: nil]; // Touch event. Comes in pairs
    [defaultCenter addObserver: self selector: @selector(onApplicationDidBecomeActive:) name: UIApplicationDidBecomeActiveNotification object: nil];
    [defaultCenter addObserver: self selector: @selector(onApplicationWillResignActive:) name: UIApplicationWillResignActiveNotification object: nil];
    [defaultCenter addObserver: self selector: @selector(onApplicationWillTerminate:) name: UIApplicationWillTerminateNotification object: nil];
    
    _sequence = 1;
    _clicks = 0;
    _totalClicks = 0;
    _keys = 0;
    _totalKeys = 0;
    
    _sessionStartTime = [[NSDate date] timeIntervalSince1970];
    
    // Calc to conform to minute offset format
    _timeZoneOffset = -60 * [[NSTimeZone localTimeZone] secondsFromGMT];
    // Collection mode for Android
    _collectMode = PLSettingCollectionMode;
    
    PLEventType eventType;
    
    // Retrieve stored Event List
    NSArray *storedEvents = (NSArray *) [NSKeyedUnarchiver unarchiveObjectWithFile:PLFileEventArchive];
    if ([storedEvents count] > 0) {
        [self.playnomicsEventList addObjectsFromArray:storedEvents];
    }
    
    // TODO check to see if we have to register the defaults first for it to work.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval lastSessionStartTime = [userDefaults doubleForKey:PLUserDefaultsLastSessionStartTime];
    NSString *lastUserId = [userDefaults stringForKey:PLUserDefaultsLastUserID];

    // Send an appStart if it has been > 3 min since the last session or
    // a
    // different user
    // otherwise send an appPage
    
    if (_sessionStartTime - lastSessionStartTime > 180
        || ![_userId isEqualToString:lastUserId]) {
        _sessionId = [[RandomGenerator createRandomHex] retain];
        
        [userDefaults setObject:_userId forKey:PLUserDefaultsLastSessionID];        
        
        _instanceId = [_sessionId retain];
        eventType = PLEventAppStart;
    }
    else {
        _sessionId = [lastUserId retain];
        _instanceId = [[RandomGenerator createRandomHex] retain];
        _sessionStartTime = lastSessionStartTime; // TODO confirm with doug that this is desired and a bug in the Java code.
        eventType = PLEventAppPage;
    }
    
    [userDefaults setDouble:_sessionStartTime forKey:PLUserDefaultsLastSessionStartTime];
    [userDefaults setObject:_userId forKey:PLUserDefaultsLastUserID];
    [userDefaults synchronize];
    
    _cookieId = [[PLUtil getDeviceUniqueIdentifier] retain];
    
    
    // Set userId to cookieId if it isn't present
    if (![_userId length]) {
        _userId = [_cookieId retain];
    }
    
    BasicEvent *ev = [[BasicEvent alloc] init:eventType 
                                applicationId:_applicationId 
                                       userId:_userId 
                                     cookieId:_cookieId 
                                    sessionId:_sessionId 
                                   instanceId:_instanceId 
                               timeZoneOffset:_timeZoneOffset];
    
    // Try to send and queue if unsuccessful
    if ([_eventSender sendEventToServer:ev]) {
        result = PLAPIResultSent;
    }
    else {
        [self.playnomicsEventList addObject:ev];
        result = PLAPIResultQueued;
    }
    [ev release];
    
    _eventTimer = [[NSTimer scheduledTimerWithTimeInterval:PLUpdateTimeInterval target:self selector:@selector(consumeQueue) userInfo:nil repeats:YES] retain];
    
    return PLAPIResultFailUnkown;    
}

/**
 * Pause.
 */
- (void) pause {
    NSLog(@"pause called");
    
    if (_sessionState == PLSessionStatePaused)
        return;
    
    _sessionState = PLSessionStatePaused;
	
    BasicEvent *ev = [[BasicEvent alloc] init:PLEventAppPause
                                applicationId:_applicationId
                                       userId:_userId
                                     cookieId:_cookieId
                                    sessionId:_sessionId
                                   instanceId:_instanceId
                               timeZoneOffset:_timeZoneOffset];
    _pauseTime = [[NSDate date] timeIntervalSince1970];    
    
    [ev setSequence:_sequence];
    [ev setSessionStartTime:_sessionStartTime];
    
    // Try to send and queue if unsuccessful
    if (![_eventSender sendEventToServer:ev]) {
        [self.playnomicsEventList addObject:ev];
    }
    [ev release];
}

/**
 * Pause
 */
- (void) resume {
    NSLog(@"resume called");
    if (_sessionState == PLSessionStateStarted) {
        return;
    }
    
    _sessionState = PLSessionStateStarted;
    
    BasicEvent *ev = [[BasicEvent alloc] init:PLEventAppResume
                                applicationId:_applicationId
                                       userId:_userId
                                     cookieId:_cookieId
                                    sessionId:_sessionId
                                   instanceId:_instanceId
                               timeZoneOffset:_timeZoneOffset];
    [ev setPauseTime:_pauseTime];
    [ev setSessionStartTime:_sessionStartTime];
    _sequence += 1;
    [ev setSequence:_sequence];
    
    
    // Try to send and queue if unsuccessful
    if (![_eventSender sendEventToServer:ev]) {
        [self.playnomicsEventList addObject:ev];
    }
    [ev release];
}

/**
 * Stop.
 * 
 * @return the API Result
 */
// TODO: Stop is not always called when the app is close. Perhaps store the Event list on pause event instead.
- (PLAPIResult) stop {
    NSLog(@"stop called");
    
    if (_sessionState == PLSessionStateStopped) {
        return PLAPIResultAlreadyStopped;
    }
    
    // TODO check that the app is closing ?
    // Currently Session is only stopped when the application quits.
    if (YES) {
        _sessionState = PLSessionStateStopped;
        
        if ([_eventTimer isValid]) {
            [_eventTimer invalidate];
        }
        [_eventTimer release];
        _eventTimer = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver: self];
        
        // Store Event List
        if (![NSKeyedArchiver archiveRootObject:self.playnomicsEventList toFile:PLFileEventArchive]) {
            NSLog(@"Playnomics: Could not save event list");
        }
    }
    
    return PLAPIResultStopped;
}

#pragma mark - Timed Event Sending
- (void) consumeQueue {
    NSLog(@"consumeQueue");
    if (_sessionState == PLSessionStateStarted) {
        _sequence++;
        
        BasicEvent *ev = [[BasicEvent alloc] init:PLEventAppRunning 
                                    applicationId:_applicationId
                                           userId:_userId
                                         cookieId:_cookieId
                                        sessionId:_sessionId
                                       instanceId:_instanceId
                                 sessionStartTime:_sessionStartTime
                                         sequence:_sequence
                                           clicks:_clicks
                                      totalClicks:_totalClicks
                                             keys:_keys
                                        totalKeys:_totalKeys
                                      collectMode:_collectMode];
        [self.playnomicsEventList addObject:ev];
        
        NSLog(@"ev:%@", ev);
        NSLog(@"self.playnomicsEventList:%@", self.playnomicsEventList);
        
        // Reset keys/clicks
        _keys = 0;
        _clicks = 0;
    }
    
    NSMutableArray *sentEvents = [[NSMutableArray alloc] init];
    for (PlaynomicsEvent *ev in self.playnomicsEventList) {
        if ([_eventSender sendEventToServer:ev]) {
            [sentEvents addObject:ev];
            continue;
        }
        // If we fail to send an event. Cancel the whole loop
        break;
    }
    [self.playnomicsEventList removeObjectsInArray:sentEvents];
}

- (PLAPIResult) sendOrQueueEvent:(PlaynomicsEvent *)pe {
    if (_sessionState != PLSessionStateStarted) {
        return PLAPIResultStartNotCalled;
    }
    
    
    PLAPIResult result;
    // Try to send and queue if unsuccessful
    if ([_eventSender sendEventToServer:pe]) {
        result = PLAPIResultSent;
    }
    else {
        [self.playnomicsEventList addObject:pe];
        result = PLAPIResultQueued;
    }
    
    return result;
}

#pragma mark - Application Event Handlers
- (void) onKeyPressed: (NSNotification *) notification {
    _keys += 1;
    _totalKeys += 1;
}


- (void) onTouchDown: (UIEvent *) event {
    _clicks += 1;
    _totalClicks += 1;
}

- (void) onApplicationWillResignActive: (NSNotification *) notification {
    [self pause];
}
- (void) onApplicationDidBecomeActive: (NSNotification *) notification {
    [self resume];
}
- (void) onApplicationWillTerminate: (NSNotification *) notification {
    [self stop];
}

#pragma mark - API request methods
+ (PLAPIResult) userInfo {
    return [PlaynomicsSession userInfoForType:PLUserInfoTypeUpdate
                                      country:nil
                                  subdivision:nil
                                          sex:0
                                     birthday:nil
                                       source:0
                               sourceCampaign:nil
                                  installTime:nil];
}

+ (PLAPIResult) userInfoForType: (PLUserInfoType) type 
                        country: (NSString *) country 
                    subdivision: (NSString *) subdivision
                            sex: (PLUserInfoSex) sex
                       birthday: (NSDate *) birthday
                         source: (PLUserInfoSource) source
                 sourceCampaign: (NSString *) sourceCampaign 
                    installTime: (NSDate *) installTime {
    // TODO: do field checks
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    UserInfoEvent *ev = [[[UserInfoEvent alloc] init:s.applicationId userId:s.userId type:type country:country subdivision:subdivision sex:sex birthday:[birthday timeIntervalSince1970] source:source sourceCampaign:sourceCampaign installTime:[installTime timeIntervalSince1970]] autorelease];
    
    return [s sendOrQueueEvent:ev];
}

+ (PLAPIResult) sessionStartWithId: (NSString *) sessionId site: (NSString *) site {
    // TODO: do field checks
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    GameEvent *ev = [[[GameEvent alloc] init:PLEventSessionStart applicationId:s.applicationId userId:s.userId sessionId:sessionId site:site instanceId:nil type:nil gameId:nil reason:nil] autorelease];
    
    return [s sendOrQueueEvent:ev];
}

+ (PLAPIResult) sessionEndWithId: (NSString *) sessionId reason: (NSString *) reason {
    // TODO: do field checks
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    GameEvent *ev = [[[GameEvent alloc] init:PLEventSessionEnd applicationId:s.applicationId userId:s.userId sessionId:sessionId site:nil instanceId:nil type:nil gameId:nil reason:reason] autorelease];
    
    return [s sendOrQueueEvent:ev];
}

+ (PLAPIResult) gameStartWithInstanceId: (NSString *) instanceId sessionId: (NSString *) sessionId site: (NSString *) site type: (NSString *) type gameId: (NSString *) gameId {
    // TODO: do field checks
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];

    // TODO check what to do with the instance id and the session id. Perhaps we should populated them ourselves.
    GameEvent *ev = [[[GameEvent alloc] init:PLEventGameStart applicationId:s.applicationId userId:s.userId sessionId:sessionId site:site instanceId:instanceId type:type gameId:gameId reason:nil] autorelease];
    
    return [s sendOrQueueEvent:ev];
}

+ (PLAPIResult) gameEndWithInstanceId: (NSString *) instanceId sessionId: (NSString *) sessionId reason: (NSString *) reason {
    // TODO: do field checks
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    GameEvent *ev = [[[GameEvent alloc] init:PLEventGameEnd applicationId:s.applicationId userId:s.userId sessionId:sessionId site:nil instanceId:instanceId type:nil gameId:nil reason:reason] autorelease];
    
    return [s sendOrQueueEvent:ev];
}


+ (PLAPIResult) transactionWithId:(long) transactionId 
                           itemId: (NSString *) itemId
                         quantity: (double) quantity
                             type: (PLTransactionType) type
                      otherUserId: (NSString *) otherUserId
                     currencyType: (PLCurrencyType) currencyType
                    currencyValue: (double) currencyValue
                 currencyCategory: (PLCurrencyCategory) currencyCategory {
    // TODO: do field checks
    NSArray *currencyTypes = [NSArray arrayWithObject: [NSNumber numberWithInt: currencyType]];
    NSArray *currencyValues = [NSArray arrayWithObject:[NSNumber numberWithDouble:currencyValue]];
    NSArray *currencyCategories = [NSArray arrayWithObject: [NSNumber numberWithInt:currencyCategory]];

    return [PlaynomicsSession transactionWithId:transactionId 
                                         itemId:itemId 
                                       quantity:quantity
                                           type:type
                                    otherUserId:otherUserId
                                  currencyTypes:currencyTypes
                                 currencyValues:currencyValues
                             currencyCategories:currencyCategories];
}


+ (PLAPIResult) transactionWithId:(long) transactionId 
                           itemId: (NSString *) itemId
                         quantity: (double) quantity
                             type: (PLTransactionType) type
                      otherUserId: (NSString *) otherUserId
                    currencyTypes: (NSArray *) currencyTypes
                   currencyValues: (NSArray *) currencyValues
               currencyCategories: (NSArray *) currencyCategories {
    // TODO: do field checks
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    TransactionEvent *ev = [[[TransactionEvent alloc] init:PLEventTransaction 
                                             applicationId:s.applicationId
                                                    userId:s.userId
                                             transactionId:transactionId 
                                                    itemId:itemId
                                                  quantity:quantity
                                                      type:type
                                               otherUserId:otherUserId
                                             currencyTypes:currencyTypes
                                            currencyValues:currencyValues
                                        currencyCategories:currencyCategories] autorelease];
    
    return [s sendOrQueueEvent:ev];
}

+ (PLAPIResult) invitationSentWithId: (NSString *) invitationId 
                     recipientUserId: (NSString *) recipientUserId 
                    recipientAddress: (NSString *) recipientAddress 
                              method: (NSString *) method {
    // TODO: do field checks
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    SocialEvent *ev = [[[SocialEvent alloc] init:PLEventInvitationSent 
                                   applicationId:s.applicationId
                                          userId:s.userId invitationId:invitationId 
                                 recipientUserId:recipientUserId 
                                recipientAddress:recipientAddress 
                                          method:method 
                                        response:0] autorelease];
    return [s sendOrQueueEvent:ev];
    
}

+ (PLAPIResult) invitationResponseWithId: (NSString *) invitationId 
                            responseType: (PLResponseType) responseType {
    // TODO: do field checks
    // TODO: recipientUserId should not be nil
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    SocialEvent *ev = [[[SocialEvent alloc] init:PLEventInvitationResponse 
                                   applicationId:s.applicationId
                                          userId:s.userId 
                                    invitationId:invitationId 
                                 recipientUserId:nil 
                                recipientAddress:nil 
                                          method:nil 
                                        response:responseType] autorelease];
    return [s sendOrQueueEvent:ev];    
}
@end

