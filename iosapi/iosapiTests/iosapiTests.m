//
//  iosapiTests.m
//  iosapiTests
//
//  Created by Douglas Kadlecek on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iosapiTests.h"
#import "PlaynomicsSession.h"
#import "EventSender.h"
#import "BasicEvent.h"
#import "SocialEvent.h"
#import "TransactionEvent.h"
#import "UserInfoEvent.h"
#import "RandomGenerator.h"
#import "GameEvent.h"

@interface PlaynomicsSession (Exposed)
+ (PlaynomicsSession *)sharedInstance;

- (void) consumeQueue;

- (void) onKeyPressed: (NSNotification *) notification;
- (void) onGestureStateChanged: (NSNotification *) notification;
- (void) onApplicationWillResignActive: (NSNotification *) notification;
- (void) onApplicationDidBecomeActive: (NSNotification *) notification;
- (void) onApplicationWillTerminate: (NSNotification *) notification;
@end

@implementation iosapiTests


- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    eventSender = [[EventSender alloc] initWithTestMode:YES];
    s = [[PlaynomicsSession sharedInstance] retain];
    long applicationId = 4L;
    NSString *userId = @"userIdTest";
    
    [PlaynomicsSession start:nil applicationId:applicationId userId:userId];
}

- (void)tearDown
{
    // Tear-down code here.
    [eventSender release];
    [s release];
    [super tearDown];    
}

- (void) _testRandomGenerator {
    for (int i = 0; i < 100; i ++) {
        NSString *hex = [RandomGenerator createRandomHex];
        STAssertTrue([hex length] == 16, @"hex:%@ length (%d) must be equal to 16", hex, [hex length]);
        
        for (int i = 0; i < [hex length]; i++) {
            char c = [hex characterAtIndex:i];
            STAssertTrue('a' <= c && c <= 'f' || '0' <= c && c <= '9' || c == ',' || c == ':', @"hex:%@ c:'%c' not a HEX", hex, c);
        }
    }
}

- (void) _testPlaynomicsSession {
    
    BOOL simulateClick = NO;
    BOOL simulateKey = NO;
    BOOL simulatePause = NO;
    BOOL simulateSendToServer = NO;
    for (int i = 0; i < 200; i++) {
        int clicks = (arc4random() % 100);
        int keys = (arc4random() % 100);
        int pause = (arc4random() % 100);
        simulateClick = clicks <= 50;
        simulateKey = keys <= 50;
        simulatePause =  pause <= 10;
        simulateSendToServer = (arc4random() % 100) <= 20;
        
        if (simulateClick) {
            for (int j = 0; j < clicks; j++) {
                [self sendClickEvent];
                
            }
        }
        if (simulateKey) {
            for (int j = 0; j < keys; j++) {
                [self sendKeyEvent];
            }
        }
        
        if (simulateSendToServer) {
            [self triggerTimer];
        }
        
        if (simulatePause) {
            [self sendSleepAwakeEvents];
        }
    }
    
    [self sendCloseEvent];
}

- (void) sendClickEvent {
    [s onGestureStateChanged:nil];
    [s onGestureStateChanged:nil];
}

- (void) sendKeyEvent {
    [s onKeyPressed:nil];
}

- (void) sendSleepAwakeEvents {
    [s onApplicationWillResignActive:nil];
    [s onApplicationDidBecomeActive:nil];
}

- (void) sendCloseEvent {
    [s onApplicationWillTerminate:nil];
}

- (void) triggerTimer {
    [s consumeQueue];
}

- (void) testBasicEvents
{
    long applicationId = 4L;
    NSString *userId = @"userIdTest";
    NSString *deviceId = @"deviceId";
    
    NSString *hex = [RandomGenerator createRandomHex];
    int timeZoneOffset = 60 * [[NSTimeZone localTimeZone] secondsFromGMT];
    
    NSLog(@"*******Sending Start & Page events *******");
    [self testSendingEvents:[NSArray arrayWithObjects: 
                             [[[BasicEvent alloc] init:PLEventAppStart applicationId:applicationId userId:userId cookieId:deviceId sessionId:hex instanceId:hex timeZoneOffset:timeZoneOffset] autorelease],
                             [[[BasicEvent alloc] init:PLEventAppPage applicationId:applicationId userId:userId cookieId:deviceId sessionId:hex instanceId:hex timeZoneOffset:timeZoneOffset] autorelease], 
                             nil]];
    
    NSLog(@"******Sending Running Events **********");
    NSMutableArray *events = [NSMutableArray array];
    NSTimeInterval sessionStartTime;
    int sequence;
    int clicks;
    int totalClicks = 0;
    int keys;
    int totalKeys = 0;
    for (int i = 0;i < 100; i++) {
        sessionStartTime =  (arc4random() % (long)[[NSDate date] timeIntervalSince1970]);
        sequence = i;
        clicks = arc4random() % 200;
        totalClicks += clicks;
        keys = arc4random() & 100;
        totalKeys += keys;
        BasicEvent *evRunning = [[[BasicEvent alloc] init:PLEventAppRunning applicationId:applicationId userId:userId cookieId:deviceId sessionId:hex instanceId:hex sessionStartTime:sessionStartTime sequence:sequence clicks:clicks totalClicks:totalClicks keys:keys totalKeys:totalKeys collectMode:8] autorelease];
        [events addObject: evRunning];
    }
    [self testSendingEvents:events];
    [events removeAllObjects];
    
    NSLog(@"******Send Pause & Resume Events **********");
    NSTimeInterval pauseTime;
    sessionStartTime = (arc4random() % (long)[[NSDate date] timeIntervalSince1970]);
    for (int i = 0;i < 10; i++) {
        sequence = i;
        pauseTime = sessionStartTime + (arc4random() % 2000);
        
        BasicEvent *evPause = [[[BasicEvent alloc] init:PLEventAppPause applicationId:applicationId userId:userId cookieId:deviceId sessionId:hex instanceId:hex timeZoneOffset:timeZoneOffset] autorelease];
        [evPause setSequence:sequence];
        [evPause setSessionStartTime:sessionStartTime];
        BasicEvent *evResume = [[[BasicEvent alloc] init:PLEventAppResume applicationId:applicationId userId:userId cookieId:deviceId sessionId:hex instanceId:hex timeZoneOffset:timeZoneOffset] autorelease];
        [evResume setSequence:sequence];
        [evResume setSessionStartTime:sessionStartTime];
        [evResume setPauseTime:pauseTime];
        [events addObject:evPause];
        [events addObject:evResume];
    }
    [self testSendingEvents:events];    
    
    NSLog(@"******Send Stop Event **********");
    [self testSendingEvents:[NSArray arrayWithObjects: 
                             [[[BasicEvent alloc] init:PLEventAppStop applicationId:applicationId userId:userId cookieId:deviceId sessionId:hex instanceId:hex timeZoneOffset:timeZoneOffset] autorelease],
                             nil]];

    
}

- (void) _testGameEvents {
    NSLog(@"****** testGameEvents **********");
    NSString *hex = [RandomGenerator createRandomHex];
    for (int i = 0;i < 10; i++) {
        [PlaynomicsSession gameStartWithInstanceId:hex sessionId:hex site:@"TEST_SITE" type:@"TEST_TYPE" gameId:@"TEST_GAMEID"];
        [PlaynomicsSession gameEndWithInstanceId:hex sessionId:hex reason:@"TEST_REASON"];
    }
}

- (void) _testSocialEvents {
    NSLog(@"****** testSocialEvents **********");
    for (int i = 0;i < 10; i++) {
        [PlaynomicsSession invitationSentWithId:@"TEST_INVITATIONID" recipientUserId:@"TEST_RECIPIENTID" recipientAddress:@"TEST_RECIPIENT_ADDRESS" method:@"TEST_METHOD"];
        // TODO: Only Response Accepted?
        [PlaynomicsSession invitationResponseWithId:@"TEST_INVITATIONID" responseType:PLResponseTypeAccepted];
    }
}

- (void) _testTransactionEvents {
    NSLog(@"****** testTransactionEvents **********");
    NSMutableArray *tTypes = [NSMutableArray arrayWithObjects:
                       [NSNumber numberWithInt:PLTransactionBuyItem], 
                       [NSNumber numberWithInt:PLTransactionBuyService], 
                       [NSNumber numberWithInt:PLTransactionCurrencyConvert], 
                       [NSNumber numberWithInt:PLTransactionFree], 
                       [NSNumber numberWithInt:PLTransactionGiftReceive], 
                       [NSNumber numberWithInt:PLTransactionGiftSend], 
                       [NSNumber numberWithInt:PLTransactionInitial], 
                       [NSNumber numberWithInt:PLTransactionReturnItem], 
                       [NSNumber numberWithInt:PLTransactionReturnService], 
                       [NSNumber numberWithInt:PLTransactionReward], 
                       [NSNumber numberWithInt:PLTransactionSellItem], 
                       [NSNumber numberWithInt:PLTransactionSellService], nil];

    NSMutableArray *shuffled = [NSMutableArray arrayWithCapacity:[tTypes count]];
    while ([tTypes count] > 0) {
        id obj = [tTypes objectAtIndex:(arc4random() % [tTypes count])];
        [tTypes removeObject:obj];
        [shuffled addObject:obj];
    }
    
    long transactionId = arc4random() % NSUIntegerMax;
    for (int i = 0;i < [shuffled count]; i++) {
        PLTransactionType type = [(NSNumber *)[shuffled objectAtIndex:i] intValue];
        [PlaynomicsSession transactionWithId:transactionId itemId:@"TEST_ITEM_ID" quantity:i type:type otherUserId:nil currencyType:PLCurrencyUSD currencyValue:(i * 13.5) currencyCategory:PLCurrencyCategoryReal];
        
        NSMutableArray *tStack = [NSMutableArray array];
        NSMutableArray *vStack = [NSMutableArray array];
        NSMutableArray *cStack = [NSMutableArray array];
        int transactionCount = arc4random() % 10;
        for (int j = 0; j < transactionCount; j++) {
            [tStack addObject:[NSNumber numberWithInt:(arc4random() % 4)]];
            [vStack addObject:[NSNumber numberWithDouble:(arc4random() % 1000) / 10]];
            [cStack addObject:[NSNumber numberWithInt:(arc4random() % 2)]];
        }
        
        [PlaynomicsSession transactionWithId:transactionId 
                                      itemId:[NSString stringWithFormat:@"TEST_ITEM_ID(%d)", i] 
                                    quantity:(arc4random() % 100) 
                                        type:type 
                                 otherUserId:nil 
                               currencyTypes:tStack 
                              currencyValues:vStack 
                          currencyCategories:cStack];
    }
}

- (void) _testSessionEvents {
    
    NSLog(@"****** testSessionEvents **********");
    
    for (int i = 0;i < 10; i++) {
        [PlaynomicsSession sessionStartWithId:[NSString stringWithFormat:@"TEST_SESSION_ID(%d)",i] site:@"TEST_SITE"];
        [PlaynomicsSession sessionEndWithId:[NSString stringWithFormat:@"TEST_SESSION_ID(%d)",i] reason:@"TEST_REASON"];
    }
    
}

- (void) _testUserInfo {
    
    NSLog(@"****** testUserInfo **********");
    
    [PlaynomicsSession userInfo];
    for (int i = 0;i < 100; i++) {
        [PlaynomicsSession userInfoForType:PLUserInfoTypeUpdate
                                   country:@"TEST_COUNTRY"
                               subdivision:@"TEST_SUBDIVISION"
                                       sex:i % 3
                                  birthday:[NSDate date]
                                    source:i % 17
                            sourceCampaign:@"TEST_SRC_CAMPAIGN"
                               installTime:[[NSDate date] dateByAddingTimeInterval:(- (double)(arc4random() % 1000000))]];
    }
}

- (void) testSendingEvents: (NSArray *) events {
    for (PlaynomicsEvent *ev in events) {
        STAssertTrue([eventSender sendEventToServer:ev], @"Failed to send event to server");
    }
}

@end
