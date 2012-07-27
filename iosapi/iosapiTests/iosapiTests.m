//
//  iosapiTests.m
//  iosapiTests
//
//  Created by Douglas Kadlecek on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iosapiTests.h"
#import "PlaynomicsSession.h"
#import "PlaynomicsSession+Exposed.h"
#import "PNEventSender.h"
#import "PNBasicEvent.h"
#import "PNSocialEvent.h"
#import "PNTransactionEvent.h"
#import "PNUserInfoEvent.h"
#import "PNRandomGenerator.h"
#import "PNGameEvent.h"

@implementation iosapiTests


- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    eventSender = [[PNEventSender alloc] initWithTestMode:YES];
    s = [[PlaynomicsSession sharedInstance] retain];

    long applicationId = 4L;
    NSString *userId = @"userIdTest";
    [PlaynomicsSession setTestMode:YES];
    [PlaynomicsSession startWithApplicationId:applicationId userId:userId];
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
        NSString *hex = [PNRandomGenerator createRandomHex];
        STAssertTrue([hex length] == 16, @"hex:%@ length (%d) must be equal to 16", hex, [hex length]);
        
        for (int i = 0; i < [hex length]; i++) {
            char c = [hex characterAtIndex:i];
            STAssertTrue('a' <= c && c <= 'f' || '0' <= c && c <= '9' || c == ',' || c == ':', @"hex:%@ c:'%c' not a HEX", hex, c);
        }
    }
}

- (void) testPlaynomicsSession {
    
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
    [s onTouchDown:nil];
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
    if ([s respondsToSelector:@selector(consumeQueue)]) {
        [s consumeQueue];
    }
}

- (void) _testBasicEvents
{
    long applicationId = 4L;
    NSString *userId = @"userIdTest";
    NSString *deviceId = @"deviceId";
    
    NSString *hex = [PNRandomGenerator createRandomHex];
    int timeZoneOffset = 60 * [[NSTimeZone localTimeZone] secondsFromGMT];
    
    NSLog(@"*******Sending Start & Page events *******");
    [self testSendingEvents:[NSArray arrayWithObjects: 
                             [[[PNBasicEvent alloc] init:PNEventAppStart applicationId:applicationId userId:userId cookieId:deviceId sessionId:hex instanceId:hex timeZoneOffset:timeZoneOffset] autorelease],
                             [[[PNBasicEvent alloc] init:PNEventAppPage applicationId:applicationId userId:userId cookieId:deviceId sessionId:hex instanceId:hex timeZoneOffset:timeZoneOffset] autorelease], 
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
        PNBasicEvent *evRunning = [[[PNBasicEvent alloc] init:PNEventAppRunning applicationId:applicationId userId:userId cookieId:deviceId sessionId:hex instanceId:hex sessionStartTime:sessionStartTime sequence:sequence clicks:clicks totalClicks:totalClicks keys:keys totalKeys:totalKeys collectMode:8] autorelease];
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
        
        PNBasicEvent *evPause = [[[PNBasicEvent alloc] init:PNEventAppPause applicationId:applicationId userId:userId cookieId:deviceId sessionId:hex instanceId:hex timeZoneOffset:timeZoneOffset] autorelease];
        [evPause setSequence:sequence];
        [evPause setSessionStartTime:sessionStartTime];
        PNBasicEvent *evResume = [[[PNBasicEvent alloc] init:PNEventAppResume applicationId:applicationId userId:userId cookieId:deviceId sessionId:hex instanceId:hex timeZoneOffset:timeZoneOffset] autorelease];
        [evResume setSequence:sequence];
        [evResume setSessionStartTime:sessionStartTime];
        [evResume setPauseTime:pauseTime];
        [events addObject:evPause];
        [events addObject:evResume];
    }
    [self testSendingEvents:events];    
    
    NSLog(@"******Send Stop Event **********");
    [self testSendingEvents:[NSArray arrayWithObjects: 
                             [[[PNBasicEvent alloc] init:PNEventAppStop applicationId:applicationId userId:userId cookieId:deviceId sessionId:hex instanceId:hex timeZoneOffset:timeZoneOffset] autorelease],
                             nil]];

    
}

- (void) testGameEvents {
    NSLog(@"****** testGameEvents **********");
    NSString *hex = [PNRandomGenerator createRandomHex];
    for (int i = 0;i < 10; i++) {
        [PlaynomicsSession gameStartWithInstanceId:hex gameSessionId:hex site:@"TEST_SITE" type:@"TEST_TYPE" gameId:@"TEST_GAMEID"];
        [PlaynomicsSession gameEndWithInstanceId:hex gameSessionId:hex reason:@"TEST_REASON"];
    }
}

- (void) testSocialEvents {
    NSLog(@"****** testSocialEvents **********");
    for (int i = 0;i < 10; i++) {
        [PlaynomicsSession invitationSentWithId:@"TEST_INVITATIONID" recipientUserId:@"TEST_RECIPIENTID" recipientAddress:@"TEST_RECIPIENT_ADDRESS" method:@"TEST_METHOD"];
        [PlaynomicsSession invitationResponseWithId:@"TEST_INVITATIONID" responseType:PNResponseTypeAccepted];
    }
}

- (void) testTransactionEvents {
    NSLog(@"****** testTransactionEvents **********");
    NSMutableArray *tTypes = [NSMutableArray arrayWithObjects:
                       [NSNumber numberWithInt:PNTransactionBuyItem], 
                       [NSNumber numberWithInt:PNTransactionBuyService], 
                       [NSNumber numberWithInt:PNTransactionCurrencyConvert], 
                       [NSNumber numberWithInt:PNTransactionFree], 
                       [NSNumber numberWithInt:PNTransactionGiftReceive], 
                       [NSNumber numberWithInt:PNTransactionGiftSend], 
                       [NSNumber numberWithInt:PNTransactionInitial], 
                       [NSNumber numberWithInt:PNTransactionReturnItem], 
                       [NSNumber numberWithInt:PNTransactionReturnService], 
                       [NSNumber numberWithInt:PNTransactionReward], 
                       [NSNumber numberWithInt:PNTransactionSellItem], 
                       [NSNumber numberWithInt:PNTransactionSellService], nil];

    NSMutableArray *shuffled = [NSMutableArray arrayWithCapacity:[tTypes count]];
    while ([tTypes count] > 0) {
        id obj = [tTypes objectAtIndex:(arc4random() % [tTypes count])];
        [tTypes removeObject:obj];
        [shuffled addObject:obj];
    }
    
    long transactionId = arc4random() % NSUIntegerMax;
    for (int i = 0;i < [shuffled count]; i++) {
        PNTransactionType type = [(NSNumber *)[shuffled objectAtIndex:i] intValue];
        [PlaynomicsSession transactionWithId:transactionId itemId:@"TEST_ITEM_ID" quantity:i type:type otherUserId:nil currencyType:PNCurrencyUSD currencyValue:(i * 13.5) currencyCategory:PNCurrencyCategoryReal];
        
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

- (void) testSessionEvents {
    
    NSLog(@"****** testSessionEvents **********");
    
    for (int i = 0;i < 10; i++) {
        [PlaynomicsSession gameSessionStartWithId:[NSString stringWithFormat:@"TEST_SESSION_ID(%d)",i] site:@"TEST_SITE"];
        [PlaynomicsSession gameSessionEndWithId:[NSString stringWithFormat:@"TEST_SESSION_ID(%d)",i] reason:@"TEST_REASON"];
    }
    
}

- (void) testUserInfo {
    
    NSLog(@"****** testUserInfo **********");
    
    [PlaynomicsSession userInfo];
    for (int i = 0;i < 100; i++) {
        [PlaynomicsSession userInfoForType:PNUserInfoTypeUpdate
                                   country:@"TEST_COUNTRY"
                               subdivision:@"TEST_SUBDIVISION"
                                       sex:i % 3
                                  birthday:[NSDate date]
                                    source:i % 17
                            sourceCampaign:@"TEST_SRC_CAMPAIGN"
                               installTime:[[NSDate date] dateByAddingTimeInterval:(- (double)(arc4random() % 1000000))]];
    }
    [PlaynomicsSession userInfoForType:PNUserInfoTypeUpdate
                               country:@"TEST_COUNTRY"
                           subdivision:@"TEST_SUBDIVISION"
                                   sex:2
                              birthday:[NSDate date]
                        sourceAsString:@"CUSTOM_SOURCE"
                        sourceCampaign:@"TEST_SRC_CAMPAIGN"
                           installTime:[[NSDate date] dateByAddingTimeInterval:(- (double)(arc4random() % 1000000))]];
}

- (void) testSendingEvents: (NSArray *) events {
    for (PNEvent *ev in events) {
        STAssertTrue([eventSender sendEventToServer:ev], @"Failed to send event to server");
    }
}

@end
