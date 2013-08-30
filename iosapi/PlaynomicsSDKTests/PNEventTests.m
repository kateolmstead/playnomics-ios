//
//  PNEventTests.m
//  iosapi
//
//  Created by Jared Jenkins on 8/29/13.
//
//

#import "PNEventTests.h"
#import "PNSession.h"
#import "PNSession+Private.h"

#import "PNDeviceManager.h"
#import "PNDeviceManager+Private.h"

#import "StubPNEventApiClient.h"
#import "StubPNCache.h"

#import "PNEventAppPage.h"
#import "PNEventAppStart.h"
#import "PNUserInfoEvent.h"

@implementation PNEventTests{
    PNSession *_session;
    StubPNEventApiClient *_stubApiClient;
    StubPNCache *_cache;
}

-(void) setUp{
    _session = [[PNSession alloc] init];
    _stubApiClient = [[StubPNEventApiClient alloc] init];
    _session.apiClient = [_stubApiClient getMockClient];
}

-(void) tearDown{
    [_cache release];
    [_stubApiClient release];
    [_session release];
}

-(id) mockCurrentDeviceInfo:(PNDeviceManager*) deviceInfo idfa: (NSUUID *) currentIdfa limitAdvertising : (BOOL) limitAdvertising idfv: (NSUUID *) currentIdfv generatedBreadcrumbID: (NSString*) breadcrumbId {
    
    id mock = [OCMockObject partialMockForObject:deviceInfo];
    
    BOOL isAdvertisingEnabled = !limitAdvertising;
    [[[mock stub] andReturnValue: OCMOCK_VALUE(isAdvertisingEnabled)] isAdvertisingTrackingEnabledFromDevice];
    [[[mock stub] andReturn: currentIdfa] getAdvertisingIdentifierFromDevice];
    [[[mock stub] andReturn: currentIdfv] getVendorIdentifierFromDevice];
    
    if(breadcrumbId){
        [[[mock stub] andReturn: breadcrumbId] generateBreadcrumbId];
    }
    return mock;
}

//runs app start with no initial device data, expects 2 events: appStart and userInfo
-(void) testAppStartNewDevice{
    NSString *breadcrumbId = nil;
    NSUUID *idfa = nil;
    BOOL limitAdvertising = NO;
    NSUUID *idfv = nil;
    
    _cache = [[StubPNCache alloc] initWithBreadcrumbID:breadcrumbId idfa:idfa idfv:idfv limitAdvertising:limitAdvertising];
    _session.cache = [_cache getMockCache];
    _session.deviceManager = [[PNDeviceManager alloc] initWithCache: _session.cache];
    
    NSUUID *currentIdfa = [[NSUUID alloc] init];
    NSUUID *currentIdfv = [[NSUUID alloc] init];
    BOOL currentLimit = NO;
    
    NSString *breadcrumb = [_session.deviceManager generateBreadcrumbId];
    
    [self mockCurrentDeviceInfo: _session.deviceManager idfa: currentIdfa limitAdvertising:currentLimit idfv:currentIdfv generatedBreadcrumbID:breadcrumb];
    
    _session.applicationId = 1;
    _session.userId = @"test-user";
    
    [_session start];
    STAssertTrue([_stubApiClient.events count] == 2, @"2 events should be queued");
    STAssertTrue([[_stubApiClient.events objectAtIndex:0] isKindOfClass:[PNEventAppStart class]], @"appStart is the first event");
    STAssertTrue([[_stubApiClient.events objectAtIndex:1] isKindOfClass:[PNUserInfoEvent class]], @"userInfo is the second event");
    
    STAssertTrue(_session.sessionId.generatedId == _session.instanceId.generatedId, @"Instance ID and Session ID should be equal.");
}

//runs app start with initial device data, expects 1 event: appStart
-(void) testAppStartNoDeviceChanges{
    NSString *breadcrumbId = @"breadcrumbId";
    NSUUID *idfa = [[NSUUID alloc] init];
    BOOL limitAdvertising = NO;
    NSUUID *idfv = [[NSUUID alloc] init];
    
    _cache = [[StubPNCache alloc] initWithBreadcrumbID:breadcrumbId idfa:idfa idfv:idfv limitAdvertising:limitAdvertising];
    _session.cache = [_cache getMockCache];
    _session.deviceManager = [[PNDeviceManager alloc] initWithCache: _session.cache];

    [self mockCurrentDeviceInfo: _session.deviceManager idfa: idfa limitAdvertising:limitAdvertising idfv:idfv generatedBreadcrumbID:breadcrumbId];

    _session.applicationId = 1;
    _session.userId = @"test-user";
    
    [_session start];
    STAssertTrue([_stubApiClient.events count] == 1, @"1 events should be queued");
    PNEventAppStart *appStart = [_stubApiClient.events objectAtIndex:0];
    STAssertNotNil(appStart, @"appStart is the first event");

    STAssertTrue(_session.sessionId.generatedId == _session.instanceId.generatedId, @"Instance ID and Session ID should be equal.");
}

//runs session start with initial device data, and lapsed previous session, expects 1 event: appStart
-(void) testAppStartLapsedSession {
    NSString *breadcrumbId = @"breadcrumbId";
    NSUUID *idfa = [[NSUUID alloc] init];
    BOOL limitAdvertising = NO;
    NSUUID *idfv = [[NSUUID alloc] init];
    
    NSString *lastUserId = breadcrumbId;
    
    NSTimeInterval now = [[NSDate new] timeIntervalSinceNow];
    NSTimeInterval tenMinutesAgo = now - 60 * 10;
    
    PNGeneratedHexId *lastSessionId = [[PNGeneratedHexId alloc] initAndGenerateValue];
    
    
    _cache = [[StubPNCache alloc] initWithBreadcrumbID:breadcrumbId idfa:idfa idfv:idfv limitAdvertising:limitAdvertising lastEventTime: tenMinutesAgo lastUserId: lastUserId lastSessionId: lastSessionId];
    _session.cache = [_cache getMockCache];
    _session.deviceManager = [[PNDeviceManager alloc] initWithCache: _session.cache];
    
    [self mockCurrentDeviceInfo: _session.deviceManager idfa: idfa limitAdvertising:limitAdvertising idfv:idfv generatedBreadcrumbID:breadcrumbId];
    
    _session.applicationId = 1;
    [_session start];
    STAssertTrue([_stubApiClient.events count] == 1, @"1 events should be queued");
    STAssertTrue([[_stubApiClient.events objectAtIndex:0] isKindOfClass:[PNEventAppStart class]], @"appStart generated after session has lapsed");

    STAssertTrue(lastSessionId.generatedId != _session.sessionId.generatedId, @"Session ID should be new.");
    STAssertTrue(_session.sessionId.generatedId == _session.instanceId.generatedId, @"Instance ID and Session ID should be equal.");
}

//runs session start with initial device data, and lapsed previous session, expects 1 event: appStart
-(void) testAppStartSwappedUser {
    NSString *breadcrumbId = @"breadcrumbId";
    NSUUID *idfa = [[NSUUID alloc] init];
    BOOL limitAdvertising = NO;
    NSUUID *idfv = [[NSUUID alloc] init];
    
    NSString *lastUserId = @"old-user-id";
    
    NSTimeInterval now = [[NSDate new] timeIntervalSinceNow];
    NSTimeInterval aMinuteAgo = now - 60 * 1;
    
    PNGeneratedHexId *lastSessionId = [[PNGeneratedHexId alloc] initAndGenerateValue];
    
    
    _cache = [[StubPNCache alloc] initWithBreadcrumbID:breadcrumbId idfa:idfa idfv:idfv limitAdvertising:limitAdvertising lastEventTime: aMinuteAgo lastUserId: lastUserId lastSessionId: lastSessionId];
    _session.cache = [_cache getMockCache];
    _session.deviceManager = [[PNDeviceManager alloc] initWithCache: _session.cache];
    
    [self mockCurrentDeviceInfo: _session.deviceManager idfa: idfa limitAdvertising:limitAdvertising idfv:idfv generatedBreadcrumbID:breadcrumbId];
    
    _session.applicationId = 1;
    [_session start];
    STAssertTrue([_stubApiClient.events count] == 1, @"1 events should be queued");
    STAssertTrue([[_stubApiClient.events objectAtIndex:0] isKindOfClass:[PNEventAppStart class]], @"appStart is generated when a new user appears");
    
    STAssertTrue(lastSessionId.generatedId != _session.sessionId.generatedId, @"Session ID should be new.");
    STAssertTrue(_session.sessionId.generatedId == _session.instanceId.generatedId, @"Instance ID and Session ID should be equal.");
}

//runs session start with device data changes, a previous startTime, expects 2 events: appPage and userInfo
-(void) testAppPauseDeviceChanges{
    NSString *breadcrumbId = @"breadcrumbId";
    NSUUID *idfa = [[NSUUID alloc] init];
    BOOL limitAdvertising = NO;
    NSUUID *idfv = [[NSUUID alloc] init];
    
    NSString *lastUserId = breadcrumbId;
    NSTimeInterval now = [[NSDate new] timeIntervalSince1970];
    NSTimeInterval aMinuteAgo = now - 60;
    
    PNGeneratedHexId *lastSessionId = [[PNGeneratedHexId alloc] initAndGenerateValue];
   
    _cache = [[StubPNCache alloc] initWithBreadcrumbID:breadcrumbId idfa:idfa idfv:idfv limitAdvertising:limitAdvertising lastEventTime: aMinuteAgo lastUserId: lastUserId lastSessionId: lastSessionId];
    _session.cache = [_cache getMockCache];
    _session.deviceManager = [[PNDeviceManager alloc] initWithCache: _session.cache];
    
    [self mockCurrentDeviceInfo: _session.deviceManager idfa: [[NSUUID alloc] init] limitAdvertising: limitAdvertising idfv: idfv generatedBreadcrumbID: breadcrumbId];

    _session.applicationId = 1;
    [_session start];
    
    STAssertTrue([_stubApiClient.events count] == 2, @"2 events should be queued");
    STAssertTrue([[_stubApiClient.events objectAtIndex:0] isKindOfClass:[PNEventAppPage class]], @"appPage is the first event");
    STAssertTrue([[_stubApiClient.events objectAtIndex:1] isKindOfClass:[PNUserInfoEvent class]], @"userInfo is the second event");
    
    STAssertTrue(lastSessionId.generatedId == _session.sessionId.generatedId, @"Session ID should be loaded from cache.");
    STAssertTrue(_session.sessionId.generatedId != _session.instanceId.generatedId, @"Instance ID and Session ID should be different.");
}

//runs session start with initial device data, a previous startTime, expects 2 events: appPage
-(void) testAppPauseNoDeviceChanges{
    NSString *breadcrumbId = @"breadcrumbId";
    NSUUID *idfa = [[NSUUID alloc] init];
    BOOL limitAdvertising = NO;
    NSUUID *idfv = [[NSUUID alloc] init];
    
    NSString *lastUserId = [breadcrumbId retain];
    
    NSTimeInterval now = [[NSDate new] timeIntervalSince1970];
    NSTimeInterval aMinuteAgo = now - 60;
    
    PNGeneratedHexId *lastSessionId = [[PNGeneratedHexId alloc] initAndGenerateValue];
    
    _cache = [[StubPNCache alloc] initWithBreadcrumbID:breadcrumbId idfa:idfa idfv:idfv limitAdvertising:limitAdvertising lastEventTime: aMinuteAgo lastUserId: lastUserId lastSessionId: lastSessionId];
    _session.cache = [_cache getMockCache];
    _session.deviceManager = [[PNDeviceManager alloc] initWithCache: _session.cache];
    
    [self mockCurrentDeviceInfo: _session.deviceManager idfa: idfa limitAdvertising:limitAdvertising idfv:idfv generatedBreadcrumbID:breadcrumbId];
    
    _session.applicationId = 1;
    [_session start];
    STAssertTrue([_stubApiClient.events count] == 1, @"1 event should be queued");
    STAssertTrue([[_stubApiClient.events objectAtIndex:0] isKindOfClass:[PNEventAppPage class]], @"appPage is the first event");
    STAssertTrue(lastSessionId.generatedId == _session.sessionId.generatedId, @"Session ID should be loaded from cache.");
    STAssertTrue(_session.sessionId.generatedId != _session.instanceId.generatedId, @"Instance ID and Session ID should be different.");
}

//runs the start, and then milestone. expects 2 events: appStart and milestone
-(void) testMilestone{
    
}

//runs the milestone without calling start first. expects 0 events
-(void) testMilestoneNoStart{
    
}

//runs start, and then transaction. expects 2 events: appStart and milestone
-(void) testTransaction{
    
}
//runs  transaction without calling start first. expects 0 events
-(void) testTransactionNoStart{
    
}

//runs start, and then enablePushNotifications, expects 2 events: appStart and enable push notifications
-(void) testEnabledPushNotifications{
    
}
//runs enablePushNotifications without calling start first. expects 0 events
-(void) testEnabledPushNoStart{
    
}

@end
