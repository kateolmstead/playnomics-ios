//
//  PlaynomicsSession.m
//  iosapi
//
//  Created by Douglas Kadlecek on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaynomicsSession.h"

#import "PNConfig.h"
#import "PNConstants.h"

#import "PNRandomGenerator.h"

#import "PNEventSender.h"

#import "PNBasicEvent.h"
#import "PNUserInfoEvent.h"
#import "PNSocialEvent.h"
#import "PNTransactionEvent.h"
#import "PNGameEvent.h"

#import "PlaynomicsSession+Exposed.h"

@interface PlaynomicsSession () {    
    PNSessionState _sessionState;

    NSTimer *_eventTimer;
    PNEventSender *_eventSender;
    NSMutableArray *_playnomicsEventList;
    
    bool _testMode; 
    /** Tracking values */
    int _collectMode;
	int _sequence;
    unsigned long long _applicationId;
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
@property (nonatomic, readonly) unsigned long long applicationId;
@property (nonatomic, readonly) NSString * userId;
@property (nonatomic, readonly) NSString * sessionId;
@property (nonatomic, assign) bool testMode;
@property (atomic, readonly) PNEventSender * eventSender;
@property (atomic, readonly) NSMutableArray * playnomicsEventList;



- (PNAPIResult) startWithApplicationId:(unsigned long long) applicationId;
- (PNAPIResult) startWithApplicationId:(unsigned long long) applicationId userId: (NSString *) userId;
- (PNAPIResult) sendOrQueueEvent: (PNEvent *) pe;

- (PNAPIResult) stop;
- (void) pause;
- (void) resume;
- (PNAPIResult) startSessionWithApplicationId: (long) applicationId;

- (void) startEventTimer;
- (void) stopEventTimer;
- (void) consumeQueue;
@end

@implementation PlaynomicsSession
@synthesize applicationId=_applicationId;
@synthesize userId=_userId;
@synthesize sessionId=_sessionId;
@synthesize testMode=_testMode;
@synthesize eventSender=_eventSender;
@synthesize playnomicsEventList=_playnomicsEventList;

//Singleton
+ (PlaynomicsSession *)sharedInstance{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

+ (void) setTestMode: (bool) testMode {
    [[PlaynomicsSession sharedInstance] eventSender].testMode = testMode;
}
 
+ (PNAPIResult) changeUserWithUserId:(NSString *)userId {
    
    [[PlaynomicsSession sharedInstance] stop];
    long appId = [PlaynomicsSession sharedInstance].applicationId;
    return [[PlaynomicsSession sharedInstance] startWithApplicationId:appId userId:userId];    
}

+ (PNAPIResult) startWithApplicationId:(unsigned long long) applicationId userId: (NSString *) userId {
    return [[PlaynomicsSession sharedInstance] startWithApplicationId:applicationId userId:userId];
}

+ (PNAPIResult) startWithApplicationId:(unsigned long long) applicationId {
    return [[PlaynomicsSession sharedInstance] startWithApplicationId:applicationId];
}

+ (PNAPIResult) stop {
    return [[PlaynomicsSession sharedInstance] stop];
}

- (id) init {
    if ((self = [super init])) {
        _collectMode = PNSettingCollectionMode;
        _sequence = 0;
        _userId = @"";
        _sessionId = @"";
        _playnomicsEventList = [[NSMutableArray alloc] init];
        _eventSender = [[PNEventSender alloc] init];
    }
    return self;
}

- (void) dealloc {
    [_eventSender release];
	[_playnomicsEventList release];
    
    /** Tracking values */
    [_userId release];
	[_cookieId release];
	[_sessionId release];
	[_instanceId release];
    
    [super dealloc];
}


#pragma mark - Session Control Methods
- (PNAPIResult) startWithApplicationId:(unsigned long long) applicationId userId: (NSString *) userId {
    _userId = [userId retain];
    return [self startWithApplicationId:applicationId];
}

- (PNAPIResult) startWithApplicationId:(unsigned long long) applicationId {
    NSLog(@"startWithApplicationId");
    if (_sessionState == PNSessionStateStarted) {
        return PNAPIResultAlreadyStarted;
    }
    
    // If paused, resume and get out of here
    if (_sessionState == PNSessionStatePaused) {
        [self resume];
        return PNAPIResultSessionResumed;
    }
    
    _applicationId = applicationId;

    PNAPIResult resval = [self startSessionWithApplicationId: applicationId];
    
    [self startEventTimer];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver: self selector: @selector(onKeyPressed:) name: UITextFieldTextDidChangeNotification object: nil];
    [defaultCenter addObserver: self selector: @selector(onKeyPressed:) name: UITextViewTextDidChangeNotification object: nil];
    [defaultCenter addObserver: self selector: @selector(onApplicationDidBecomeActive:) name: UIApplicationDidBecomeActiveNotification object: nil];
    [defaultCenter addObserver: self selector: @selector(onApplicationWillResignActive:) name: UIApplicationWillResignActiveNotification object: nil];
    [defaultCenter addObserver: self selector: @selector(onApplicationWillTerminate:) name: UIApplicationWillTerminateNotification object: nil];
    
    
    // Retrieve stored Event List
    NSArray *storedEvents = (NSArray *) [NSKeyedUnarchiver unarchiveObjectWithFile:PNFileEventArchive];
    if ([storedEvents count] > 0) {
        [self.playnomicsEventList addObjectsFromArray:storedEvents];
        
        // Remove archive so as not to pick up bad events when starting up next time.
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:PNFileEventArchive error:nil];
    }
    
    return resval;
}

- (PNAPIResult) startSessionWithApplicationId: (long) applicationId {
    NSLog(@"startSessionWithApplicationId");
    
    /** Setting Session variables */
    
    _sessionState = PNSessionStateStarted;
    _applicationId = applicationId;
    
    _cookieId = [[PNUtil getDeviceUniqueIdentifier] retain];
    
    // Set userId to cookieId if it isn't present
    if ([_userId length] == 0) {
        _userId = [_cookieId retain];
    }
    
    _collectMode = PNSettingCollectionMode;
    
    _timeZoneOffset = -60 * [[NSTimeZone localTimeZone] secondsFromGMT];
    _sequence = 1;
    _clicks = 0;
    _totalClicks = 0;
    _keys = 0;
    _totalKeys = 0;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastUserId = [userDefaults stringForKey:PNUserDefaultsLastUserID];
    NSTimeInterval lastSessionStartTime = [[NSUserDefaults standardUserDefaults] doubleForKey:PNUserDefaultsLastSessionStartTime];
    
    PNEventType eventType;
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    // Send an appStart if it has been > 3 min since the last session or
    // a
    // different user
    // otherwise send an appPage    
    if ((currentTime - lastSessionStartTime > PNSessionTimeout)
        || ![_userId isEqualToString:lastUserId]) {
        _sessionId = [[PNRandomGenerator createRandomHex] retain];
        _instanceId = [_sessionId retain];
        _sessionStartTime = currentTime;
        
        eventType = PNEventAppStart;
        
        [userDefaults setDouble:_sessionStartTime forKey:PNUserDefaultsLastSessionStartTime];
        [userDefaults setObject:_userId forKey:PNUserDefaultsLastUserID];
        [userDefaults synchronize];
    }
    else {
        if (_sessionId == nil)
            _sessionId = [[PNRandomGenerator createRandomHex] retain];

        // Always create a new Instance Id
        _instanceId = [[PNRandomGenerator createRandomHex] retain];
        _sessionStartTime = [userDefaults doubleForKey:PNUserDefaultsLastSessionStartTime];
        
        eventType = PNEventAppPage;
    }
    
    /** Send appStart or appPage event */
    PNBasicEvent *ev = [[PNBasicEvent alloc] init:eventType 
                                applicationId:_applicationId 
                                       userId:_userId 
                                     cookieId:_cookieId 
                                    sessionId:_sessionId 
                                   instanceId:_instanceId 
                               timeZoneOffset:_timeZoneOffset];
    
    // Try to send and queue if unsuccessful
    [_eventSender sendEventToServer:ev withEventQueue:_playnomicsEventList];
    [ev release];
    
    return PNAPIResultSent;
}

/**
 * Pause.
 */
- (void) pause {
    NSLog(@"pause called");
    
    if (_sessionState == PNSessionStatePaused)
        return;
    
    _sessionState = PNSessionStatePaused;    
    
    [self stopEventTimer];
	
    PNBasicEvent *ev = [[[PNBasicEvent alloc] init:PNEventAppPause
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
                                       collectMode:_collectMode] autorelease];
    _pauseTime = [[NSDate date] timeIntervalSince1970];
    
    _sequence += 1;    
    [ev setSequence:_sequence];
    [ev setSessionStartTime:_sessionStartTime];
    
    // Try to send and queue if unsuccessful
    [_eventSender sendEventToServer:ev withEventQueue:_playnomicsEventList];
}

/**
 * Pause
 */
- (void) resume {
    NSLog(@"resume called");
    
    if (_sessionState == PNSessionStateStarted) {
        return;
    }
    
    [self startEventTimer];
    
    _sessionState = PNSessionStateStarted;
    
    PNBasicEvent *ev = [[[PNBasicEvent alloc] init:PNEventAppResume 
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
                                       collectMode:_collectMode] autorelease];
    [ev setPauseTime:_pauseTime];
    [ev setSessionStartTime:_sessionStartTime];
    [ev setSequence:_sequence];
    
    
    // Try to send and queue if unsuccessful
    [_eventSender sendEventToServer:ev withEventQueue:_playnomicsEventList];
}

/**
 * Stop.
 * 
 * @return the API Result
 */
- (PNAPIResult) stop {
    NSLog(@"stop called");
    
    if (_sessionState == PNSessionStateStopped) {
        return PNAPIResultAlreadyStopped;
    }
    
    // Currently Session is only stopped when the application quits.
    _sessionState = PNSessionStateStopped;
    
    [self stopEventTimer];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    // Store Event List
    if (![NSKeyedArchiver archiveRootObject:self.playnomicsEventList toFile:PNFileEventArchive]) {
        NSLog(@"Playnomics: Could not save event list");
    }
    
    return PNAPIResultStopped;
}

#pragma mark - Timed Event Sending
- (void) startEventTimer {
    [self stopEventTimer];
        
    _eventTimer = [[NSTimer scheduledTimerWithTimeInterval:PNUpdateTimeInterval target:self selector:@selector(consumeQueue) userInfo:nil repeats:YES] retain];
}

- (void) stopEventTimer {
    if ([_eventTimer isValid]) {
        [_eventTimer invalidate];
    }
    [_eventTimer release];
    _eventTimer = nil;
}

- (void) consumeQueue {
    NSLog(@"consumeQueue");
    if (_sessionState == PNSessionStateStarted) {
        _sequence++;
        
        PNBasicEvent *ev = [[[PNBasicEvent alloc] init:PNEventAppRunning 
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
                                      collectMode:_collectMode] autorelease];
        [self.playnomicsEventList addObject:ev];
        
        NSLog(@"ev:%@", ev);
        NSLog(@"self.playnomicsEventList:%@", self.playnomicsEventList);
        
        // Reset keys/clicks
        _keys = 0;
        _clicks = 0;
    }
    
    for (PNEvent *ev in self.playnomicsEventList) {
        [_eventSender sendEventToServer:ev withEventQueue:_playnomicsEventList];
    }
}

- (PNAPIResult) sendOrQueueEvent:(PNEvent *)pe {
    if (_sessionState != PNSessionStateStarted) {
        return PNAPIResultStartNotCalled;
    }
        
    // Try to send and queue if unsuccessful
    [_eventSender sendEventToServer:pe withEventQueue:_playnomicsEventList];    
    return PNAPIResultSent;
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
+ (PNAPIResult) userInfo {
    return [PlaynomicsSession userInfoForType:PNUserInfoTypeUpdate
                                      country:nil
                                  subdivision:nil
                                          sex:0
                                     birthday:nil
                                       source:0
                               sourceCampaign:nil
                                  installTime:nil];
}

+ (PNAPIResult) userInfoForType: (PNUserInfoType) type 
                        country: (NSString *) country 
                    subdivision: (NSString *) subdivision
                            sex: (PNUserInfoSex) sex
                       birthday: (NSDate *) birthday
                         source: (PNUserInfoSource) source
                 sourceCampaign: (NSString *) sourceCampaign 
                    installTime: (NSDate *) installTime {
    return [PlaynomicsSession userInfoForType:type
                               country:country
                           subdivision:subdivision
                                   sex:sex 
                              birthday:birthday
                        sourceAsString:[PNUtil PNUserInfoSourceDescription:source]
                        sourceCampaign:sourceCampaign
                           installTime:installTime];
}

+ (PNAPIResult) userInfoForType: (PNUserInfoType) type 
                        country: (NSString *) country 
                    subdivision: (NSString *) subdivision
                            sex: (PNUserInfoSex) sex
                       birthday: (NSDate *) birthday
                 sourceAsString: (NSString *) source 
                 sourceCampaign: (NSString *) sourceCampaign 
                    installTime: (NSDate *) installTime {
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    PNUserInfoEvent *ev = [[[PNUserInfoEvent alloc] init:s.applicationId userId:s.userId type:type country:country subdivision:subdivision sex:sex birthday:[birthday timeIntervalSince1970] source:source sourceCampaign:sourceCampaign installTime:[installTime timeIntervalSince1970]] autorelease];
    
    ev.sessionId = [[PlaynomicsSession sharedInstance] sessionId];
    return [s sendOrQueueEvent:ev];    
}

+ (PNAPIResult) gameSessionStartWithId: (NSString *) gameSessionId site: (NSString *) site {
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    PNGameEvent *ev = [[[PNGameEvent alloc] init:PNEventSessionStart applicationId:s.applicationId userId:s.userId gameSessionId:gameSessionId site:site instanceId:nil type:nil gameId:nil reason:nil] autorelease];
    
    ev.sessionId = [[PlaynomicsSession sharedInstance] sessionId];
    return [s sendOrQueueEvent:ev];
}

+ (PNAPIResult) gameSessionEndWithId: (NSString *) gameSessionId reason: (NSString *) reason {
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    PNGameEvent *ev = [[[PNGameEvent alloc] init:PNEventSessionEnd applicationId:s.applicationId userId:s.userId gameSessionId:gameSessionId site:nil instanceId:nil type:nil gameId:nil reason:reason] autorelease];
    
    ev.sessionId = [[PlaynomicsSession sharedInstance] sessionId];
    return [s sendOrQueueEvent:ev];
}

+ (PNAPIResult) gameStartWithInstanceId: (NSString *) instanceId gameSessionId: (NSString *) gameSessionId site: (NSString *) site type: (NSString *) type gameId: (NSString *) gameId {
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];

    PNGameEvent *ev = [[[PNGameEvent alloc] init:PNEventGameStart applicationId:s.applicationId userId:s.userId gameSessionId:gameSessionId site:site instanceId:instanceId type:type gameId:gameId reason:nil] autorelease];
    
    ev.sessionId = [[PlaynomicsSession sharedInstance] sessionId];
    return [s sendOrQueueEvent:ev];
}

+ (PNAPIResult) gameEndWithInstanceId: (NSString *) instanceId gameSessionId: (NSString *) gameSessionId reason: (NSString *) reason {
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    PNGameEvent *ev = [[[PNGameEvent alloc] init:PNEventGameEnd applicationId:s.applicationId userId:s.userId gameSessionId:gameSessionId site:nil instanceId:instanceId type:nil gameId:nil reason:reason] autorelease];
    
    ev.sessionId = [[PlaynomicsSession sharedInstance] sessionId];
    return [s sendOrQueueEvent:ev];
}


+ (PNAPIResult) transactionWithId:(long) transactionId 
                           itemId: (NSString *) itemId
                         quantity: (double) quantity
                             type: (PNTransactionType) type
                      otherUserId: (NSString *) otherUserId
                     currencyType: (PNCurrencyType) currencyType
                    currencyValue: (double) currencyValue
                 currencyCategory: (PNCurrencyCategory) currencyCategory {
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

+ (PNAPIResult) transactionWithId:(long) transactionId 
                           itemId: (NSString *) itemId
                         quantity: (double) quantity
                             type: (PNTransactionType) type
                      otherUserId: (NSString *) otherUserId
             currencyTypeAsString: (NSString *) currencyType
                    currencyValue: (double) currencyValue
                 currencyCategory: (PNCurrencyCategory) currencyCategory {
    NSArray *currencyTypes = [NSArray arrayWithObject: currencyType];
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


+ (PNAPIResult) transactionWithId:(long) transactionId 
                           itemId: (NSString *) itemId
                         quantity: (double) quantity
                             type: (PNTransactionType) type
                      otherUserId: (NSString *) otherUserId
                    currencyTypes: (NSArray *) currencyTypes
                   currencyValues: (NSArray *) currencyValues
               currencyCategories: (NSArray *) currencyCategories {
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    PNTransactionEvent *ev = [[[PNTransactionEvent alloc] init:PNEventTransaction 
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
    
    ev.sessionId = [[PlaynomicsSession sharedInstance] sessionId];
    return [s sendOrQueueEvent:ev];
}

+ (PNAPIResult) invitationSentWithId: (NSString *) invitationId 
                     recipientUserId: (NSString *) recipientUserId 
                    recipientAddress: (NSString *) recipientAddress 
                              method: (NSString *) method {
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    PNSocialEvent *ev = [[[PNSocialEvent alloc] init:PNEventInvitationSent 
                                   applicationId:s.applicationId
                                          userId:s.userId invitationId:invitationId 
                                 recipientUserId:recipientUserId 
                                recipientAddress:recipientAddress 
                                          method:method 
                                        response:0] autorelease];
    ev.sessionId = [[PlaynomicsSession sharedInstance] sessionId];
    return [s sendOrQueueEvent:ev];
    
}

+ (PNAPIResult) invitationResponseWithId: (NSString *) invitationId 
                            responseType: (PNResponseType) responseType {
    // TODO: recipientUserId should not be nil
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    PNSocialEvent *ev = [[[PNSocialEvent alloc] init:PNEventInvitationResponse 
                                   applicationId:s.applicationId
                                          userId:s.userId 
                                    invitationId:invitationId 
                                 recipientUserId:nil 
                                recipientAddress:nil 
                                          method:nil 
                                        response:responseType] autorelease];
    ev.sessionId = [[PlaynomicsSession sharedInstance] sessionId];
    return [s sendOrQueueEvent:ev];    
}
@end

