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

// TODO update PLCollectionMode for iOS
int const PLSettingCollectionMode = 7;

@interface PlaynomicsSession () {
    id<PlaynomicsApiDelegate> _delegate;
    
    EventSender *_eventSender;
    
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

+ (PlaynomicsSession *)sharedInstance;

- (PLAPIResult) start: (id<PlaynomicsApiDelegate>) delegate applicationId:(long) applicationId;
- (PLAPIResult) stop;
- (void) pause;
- (void) resume;
@end

@interface PlaynomicsSession (Util) 
- (NSString *) getDeviceUniqueIdentifier;
@end

@implementation PlaynomicsSession

//Singleton
+ (PlaynomicsSession *)sharedInstance{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
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
        
        _eventSender = [[EventSender alloc] init];
    }
    return self;
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
    
    BasicEvent *be = [[BasicEvent alloc] init:eventType 
                                applicationId:_applicationId 
                                       userId:_userId 
                                     cookieId:_cookieId 
                                    sessionId:_sessionId 
                                   instanceId:_instanceId 
                               timeZoneOffset:_timeZoneOffset];
    
    // Try to send and queue if unsuccessful
    if ([_eventSender sendEventToServer:be]) {
        result = PLAPIResultSent;
    }
    else {
        // TODO: Queue be event
        result = PLAPIResultQueued;
    }
    
    // TODO: Startup the event timer to send events back to the server
    
    
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
	
    BasicEvent *be = [[BasicEvent alloc] init:PLEventAppPause
                                applicationId:_applicationId
                                       userId:_userId
                                     cookieId:_cookieId
                                    sessionId:_sessionId
                                   instanceId:_instanceId
                               timeZoneOffset:_timeZoneOffset];
    _pauseTime = [[NSDate date] timeIntervalSince1970];    
    
    [be setSequence:_sequence];
    [be setSessionStartTime:_sessionStartTime];
    
    // Try to send and queue if unsuccessful
    if (![_eventSender sendEventToServer:be]) {
        // TODO save event to queue
    }
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
    
    BasicEvent *be = [[BasicEvent alloc] init:PLEventAppResume
                                applicationId:_applicationId
                                       userId:_userId
                                     cookieId:_cookieId
                                    sessionId:_sessionId
                                   instanceId:_instanceId
                               timeZoneOffset:_timeZoneOffset];
    [be setPauseTime:_pauseTime];
    [be setSessionStartTime:_sessionStartTime];
    _sequence += 1;
    [be setSequence:_sequence];
    
    
    // Try to send and queue if unsuccessful
    if (![_eventSender sendEventToServer:be]) {
        // TODO save event to queue
    }
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
        // TODO turn of event timer
        
        // TODO: Save event list
        
        _delegate = nil;
    }
    
    return PLAPIResultStopped;
}

+ (PLAPIResult) userInfo {
    return PLAPIResultFailUnkown;
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
@end
