//
//  PlaynomicsSession.m
//  iosapi
//
//  Created by Douglas Kadlecek on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaynomicsSession.h"

#import "EventSender.h"
#import "RandomGenerator.h"

#import "BasicEvent.h"
#import "UserInfoEvent.h"
#import "SocialEvent.h"
#import "TransactionEvent.h"
#import "GameEvent.h"

// TODO update PLCollectionMode to that of iOS
int const PLSettingCollectionMode = 7;
const NSTimeInterval UPDATE_INTERVAL = 60;

@interface PlaynomicsSession () {
    id<PlaynomicsApiDelegate> _delegate;
    
    NSTimer *_eventTimer;
    EventSender *_eventSender;
    NSMutableArray *_playnomicsEventList;
    
    
    /** Tracking values */
    int _collectMode;
	int _sequence;
    long _applicationId;
    NSString *_userId;
	NSString *_cookieId;
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
@property (atomic, readonly) NSMutableArray *   playnomicsEventList;
@property (nonatomic, readonly) long            applicationId;
@property (nonatomic, readonly) NSString *      userId;

+ (PlaynomicsSession *)sharedInstance;

- (PLAPIResult) start: (id<PlaynomicsApiDelegate>) delegate applicationId:(long) applicationId;
- (PLAPIResult) start: (id<PlaynomicsApiDelegate>) delegate 
        applicationId:(long) applicationId userId: (NSString *) userId;
- (PLAPIResult) stop;
- (void) pause;
- (void) resume;

- (void) consumeQueue;
@end

@interface PlaynomicsSession (EventsPrivate)
- (PLAPIResult) sendOrQueueEvent: (PlaynomicsEvent *) pe;
@end

@interface PlaynomicsSession (Util) 
- (NSString *) getDeviceUniqueIdentifier;
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

+ (PLAPIResult) start: (id<PlaynomicsApiDelegate>) delegate 
        applicationId:(long) applicationId userId: (NSString *) userId {
    return [[PlaynomicsSession sharedInstance] start:delegate applicationId:applicationId userId:userId];
}

+ (PLAPIResult) start: (id<PlaynomicsApiDelegate>) delegate applicationId:(long) applicationId {
    return [[PlaynomicsSession sharedInstance] start:delegate applicationId:applicationId];
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

- (PLAPIResult) start: (id<PlaynomicsApiDelegate>) delegate applicationId:(long) applicationId userId: (NSString *) userId {
    _userId = [userId retain];
    return [self start:delegate applicationId:applicationId];
}

- (PLAPIResult) start: (id<PlaynomicsApiDelegate>) delegate applicationId:(long) applicationId {
    if (_sessionState == PLSessionStateStarted)
        return PLAPIResultAlreadyStarted;
    
    // If paused, resume and get out of here
    if (_sessionState == PLSessionStatePaused) {
        [self resume];
        return PLAPIResultSessionResumed;
    }
    
    PLAPIResult result;
    
    _sessionState = PLSessionStateStarted;
    
    _delegate = delegate;
    _applicationId = applicationId;
    
    // TODO: register observers
    // See http://stackoverflow.com/questions/1267560/iphone-keyboard-event
    // >>>>>>>>>>>>> http://stackoverflow.com/questions/5073293/what-are-all-the-types-of-nsnotifications
    
    _sequence = 1;
    _clicks = 0;
    _totalClicks = 0;
    _keys = 0;
    _totalKeys = 0;
    
    _sessionStartTime = [[NSDate date] timeIntervalSince1970];

    // Calc to conform to minute offset format
    _timeZoneOffset = 60 * [[NSTimeZone localTimeZone] secondsFromGMT];
    // Collection mode for Android
    _collectMode = PLSettingCollectionMode;
    
    PLEventType eventType;
    
    // TODO retrieve stored Event List
    // TODO retrieve last session time
    NSTimeInterval lastSessionStartTime = 0;
    NSString *lastUserId = @"333";
    
    // Send an appStart if it has been > 3 min since the last session or
    // a
    // different user
    // otherwise send an appPage
    if (_sessionStartTime - lastSessionStartTime > 18000
        || ![_userId isEqualToString:lastUserId]) {
        _sessionId = [[RandomGenerator createRandomHex] retain];
        
        // TODO save new Session Id
        _instanceId = _sessionId;
        eventType = PLEventAppStart;
    }
    else {
        _sessionId = [lastUserId retain];
        eventType = PLEventAppPage;
    }
    
    // TODO: Save userId
    // TODO: Save _sessionStartType
    
    _cookieId = [self getDeviceUniqueIdentifier];
    
    
    // Set userId to cookieId if it isn't present
    if (![_userId length]) {
        _userId = _cookieId;
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
    
    _eventTimer = [[NSTimer scheduledTimerWithTimeInterval:UPDATE_INTERVAL target:self selector:@selector(consumeQueue) userInfo:nil repeats:YES] retain];
    
    return PLAPIResultFailUnkown;    
}

- (void) consumeQueue {
    if (_sessionState == PLSessionStateStarted) {
        _sequence++;
        
        BasicEvent *ev = [[BasicEvent alloc] init:PLEventAppRunning applicationId:_applicationId userId:_userId cookieId:_cookieId sessionId:_sessionId instanceId:_instanceId timeZoneOffset:_timeZoneOffset];
        [self.playnomicsEventList addObject:ev];
        
        // Reset keys/clicks
        _keys = 0;
        _clicks = 0;
    }
    
    NSMutableArray *sentEvents = [[NSMutableArray alloc] init];
    for (PlaynomicsEvent *ev in self.playnomicsEventList) {
        if ([_eventSender sendEventToServer:ev]) {
            [sentEvents addObject:ev];
        }
        else {
            break;
        }
    }
    [self.playnomicsEventList removeObjectsInArray:sentEvents];
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
- (PLAPIResult) stop {
    NSLog(@"stop called");
    
    if (_sessionState == PLSessionStateStopped) {
        return PLAPIResultAlreadyStopped;
    }

    // TODO check that the app is closing
    if (YES) {
        _sessionState = PLSessionStateStopped;
        
        if ([_eventTimer isValid]) {
            [_eventTimer invalidate];
        }
        [_eventTimer release];
        _eventTimer = nil;
        
        // TODO: Unregister observers
        
        // TODO: Save event list
        
        _delegate = nil;
    }
    
    return PLAPIResultStopped;
}



+ (PLAPIResult) userInfo {
    return [PlaynomicsSession userInfoForType:PLUserInfoTypeUpdate
                                      country:nil
                                  subdivision:nil
                                          sex:nil
                                     birthday:nil
                                    sourceStr:@""
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
    return [PlaynomicsSession userInfoForType:type
                                      country:country
                                  subdivision:subdivision
                                          sex:sex
                                     birthday:birthday
                                    sourceStr:[PLUtil PLUserInfoSourceDescription:source]
                               sourceCampaign:sourceCampaign
                                  installTime:installTime];
}

+ (PLAPIResult) userInfoForType: (PLUserInfoType) type 
                        country: (NSString *) country 
                    subdivision: (NSString *) subdivision
                            sex: (PLUserInfoSex) sex
                       birthday: (NSDate *) birthday
                      sourceStr: (NSString *) sourceStr 
                 sourceCampaign: (NSString *) sourceCampaign 
                    installTime: (NSDate *) installTime {
    
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    UserInfoEvent *ev = [[[UserInfoEvent alloc] init:s.applicationId userId:s.userId type:type country:country subdivision:subdivision sex:sex birthday:birthday source:sourceStr sourceCampaign:sourceCampaign installTime:installTime] autorelease];
    
    return [s sendOrQueueEvent:ev];
}

+ (PLAPIResult) sessionStart: (NSString *) sessionId site: (NSString *) site {
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    GameEvent *ev = [[[GameEvent alloc] init:PLEventSessionStart applicationId:s.applicationId userId:s.userId sessionId:sessionId site:site instanceId:nil type:nil gameId:nil reason:nil] autorelease];
    
    return [s sendOrQueueEvent:ev];
}

+ (PLAPIResult) sessionEnd: (NSString *) sessionId reason: (NSString *) reason {
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    GameEvent *ev = [[[GameEvent alloc] init:PLEventSessionEnd applicationId:s.applicationId userId:s.userId sessionId:sessionId site:nil instanceId:nil type:nil gameId:nil reason:reason] autorelease];
    
    return [s sendOrQueueEvent:ev];
}

+ (PLAPIResult) gameStartWithInstanceId: (NSString *) instanceId sessionId: (NSString *) sessionId site: (NSString *) site type: (NSString *) type gameId: (NSString *) gameId {
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    GameEvent *ev = [[[GameEvent alloc] init:PLEventGameStart applicationId:s.applicationId userId:s.userId sessionId:sessionId site:site instanceId:instanceId type:type gameId:gameId reason:nil] autorelease];
    
    return [s sendOrQueueEvent:ev];
}

+ (PLAPIResult) gameStartWithInstanceId: (NSString *) instanceId sessionId: (NSString *) sessionId reason: (NSString *) reason {
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    GameEvent *ev = [[[GameEvent alloc] init:PLEventGameEnd applicationId:s.applicationId userId:s.userId sessionId:sessionId site:nil instanceId:instanceId type:nil gameId:nil reason:reason] autorelease];
    
    return [s sendOrQueueEvent:ev];
}


+ (PLAPIResult) transaction:(long) transactionId 
                     itemId: (NSString *) itemId
                   quantity: (double) quantity
                       type: (PLTransactionType) type
                otherUserId: (NSString *) otherUserId
               currencyType: (PLCurrencyType) currencyType
              currencyValue: (double) currencyValue
           currencyCategory: (PLCurrencyCategory) currencyCategory {
    return [PlaynomicsSession transaction:transactionId 
                                   itemId:itemId 
                                 quantity:quantity
                                     type:type
                              otherUserId:otherUserId
                          currencyTypeStr:[PLUtil PLCurrencyTypeDescription:currencyType]
                            currencyValue:currencyValue
                         currencyCategory:currencyCategory];
}


+ (PLAPIResult) transaction:(long) transactionId 
                     itemId: (NSString *) itemId
                   quantity: (double) quantity
                       type: (PLTransactionType) type
                otherUserId: (NSString *) otherUserId
            currencyTypeStr: (NSString *) currencyType
              currencyValue: (double) currencyValue
           currencyCategory: (PLCurrencyCategory) currencyCategory {
    NSArray *currencyTypes = [NSArray arrayWithObject:currencyType];
    NSArray *currencyValues = [NSArray arrayWithObject:[NSNumber numberWithDouble:currencyValue]];
    NSArray *currencyCategories = [NSArray arrayWithObject:[PLUtil PLCurrencyCategoryDescription:currencyCategory]];
    
    return [PlaynomicsSession transaction:transactionId 
                                   itemId:itemId 
                                 quantity:quantity
                                     type:type
                              otherUserId:otherUserId
                          currencyTypesStr:currencyTypes
                            currencyValues:currencyValues
                         currencyCategories:currencyCategories];
}

+ (PLAPIResult) transaction:(long) transactionId 
                     itemId: (NSString *) itemId
                   quantity: (double) quantity
                       type: (PLTransactionType) type
                otherUserId: (NSString *) otherUserId
           currencyTypesStr: (NSArray *) currencyTypes
             currencyValues: (NSArray *) currencyValues
         currencyCategories: (NSArray *) currencyCategories {
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

+ (PLAPIResult) invitationSent: (NSString *) invitationId 
               recipientUserId: (NSString *) recipientUserId 
              recipientAddress: (NSString *) recipientAddress 
                        method: (NSString *) method {
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    SocialEvent *ev = [[[SocialEvent alloc] init:PLEventInvitationSent 
                                   applicationId:s.applicationId
                                          userId:s.userId invitationId:invitationId 
                                 recipientUserId:recipientUserId 
                                recipientAddress:recipientAddress 
                                          method:method 
                                        response:nil] autorelease];
    return [s sendOrQueueEvent:ev];

}

+ (PLAPIResult) invitationSent: (NSString *) invitationId responseType: (PLResponseType) responseType {
    PlaynomicsSession * s =[PlaynomicsSession sharedInstance];
    
    SocialEvent *ev = [[[SocialEvent alloc] init:PLEventInvitationResponse 
                                   applicationId:s.applicationId
                                          userId:s.userId invitationId:invitationId 
                                 recipientUserId:nil 
                                recipientAddress:nil 
                                          method:nil 
                                        response:responseType] autorelease];
    return [s sendOrQueueEvent:ev];    
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
        [_playnomicsEventList addObject:pe];
        result = PLAPIResultQueued;
    }
    
    return result;
}
                      

/*  The Pasteboard is kept in memory even if the app is deleted.
 *  This provides a suitable means for having a unique device ID
 */
- (NSString *) getDeviceUniqueIdentifier {
    UIPasteboard *pasteBoard = [UIPasteboard pasteboardWithName:@"com.playnomics.uniqueDeviceId" create:YES];
    NSString *storedUUID = [pasteBoard string];
    
    if (![storedUUID length]) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        storedUUID = (NSString *)CFUUIDCreateString(NULL,uuidRef);
        CFRelease(uuidRef);
        pasteBoard.string = storedUUID;
    }
    return storedUUID;
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
@end

