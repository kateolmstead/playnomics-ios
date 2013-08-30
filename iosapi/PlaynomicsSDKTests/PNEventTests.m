//
//  PNEventTests.m
//  iosapi
//  Created by Jared Jenkins on 8/30/13.
//
//

#import "PNEventTests.h"

#import "PNEventAppPage.h"
#import "PNEventAppStart.h"
#import "PNEventAppPause.h"
#import "PNEventAppResume.h"
#import "PNEventAppRunning.h"
#import "PNEventMilestone.h"
#import "PNEventTransaction.h"
#import "PNGeneratedHexId.h"
#import "PNEventUserInfo.h"
#import "PNConstants.h"
#import "PNConfig.h"
#import "PNUtil.h"

@implementation PNEventTests{
    PNGameSessionInfo *_info;
    PNGeneratedHexId *_instanceId;
}

-(void) setUp{
    _info = [[self getGameSessionInfo] retain];
    _instanceId = [[PNGeneratedHexId alloc] initAndGenerateValue];
}

-(void) tearDown {
    [_info release];
}

- (PNGameSessionInfo *) getGameSessionInfo{
    PNGameSessionInfo *info = [[PNGameSessionInfo alloc] initWithApplicationId:1 userId:@"user-name" breadcrumbId:@"breadcrumbId" sessionId:[[PNGeneratedHexId alloc] initAndGenerateValue]];
    return [info autorelease];
}

-(void) assertCommonInfoIsAvailable: (PNEvent*) event sessionInfo: (PNGameSessionInfo *) session {
    STAssertEqualObjects([event.eventParameters valueForKey:@"a"], session.applicationId, @"Application ID is set");
    STAssertEqualObjects([event.eventParameters valueForKey:@"u"], session.userId, @"User ID is set");
    STAssertEqualObjects([event.eventParameters valueForKey:@"b"], session.breadcrumbId, @"Breadcrumb ID is set");
    STAssertEqualObjects([event.eventParameters valueForKey:@"t"], [NSNumber numberWithLongLong: event.eventTime * 1000], @"Event time is set");
    STAssertEqualObjects([event.eventParameters valueForKey:@"ever"], PNPropertyVersion, @"SDK Version is set");
    STAssertEqualObjects([event.eventParameters valueForKey:@"esrc"], @"ios", @"SDK Name is set");
    
    if([event isKindOfClass:[PNImplicitEvent class]]){
        STAssertEqualObjects([event sessionKey], @"s", @"Session key is set correctly");
    } else {
        STAssertEqualObjects([event sessionKey], @"jsh", @"Session key is set correctly");
    }
    
    STAssertEqualObjects([event.eventParameters valueForKey:[event sessionKey]], [session.sessionId toHex], @"Session ID is set");
    
    if([event isKindOfClass:[PNEventAppStart class]]){
        STAssertEqualObjects([event baseUrlPath], @"appStart", @"Has correct URL Path");
    } else if([event isKindOfClass:[PNEventAppPage class]]){
        STAssertEqualObjects([event baseUrlPath], @"appPage", @"Has correct URL Path");
    } else if([event isKindOfClass:[PNEventAppResume class]]){
        STAssertEqualObjects([event baseUrlPath], @"appResume", @"Has correct URL Path");
    } else if([event isKindOfClass:[PNEventAppPause class]]){
        STAssertEqualObjects([event baseUrlPath], @"appPause", @"Has correct URL Path");
    } else if([event isKindOfClass:[PNEventAppRunning class]]){
        STAssertEqualObjects([event baseUrlPath], @"appRunning", @"Has correct URL Path");
    } else if([event isKindOfClass:[PNEventTransaction class]]){
        STAssertEqualObjects([event baseUrlPath], @"transaction", @"Has correct URL Path");
    } else if([event isKindOfClass:[PNEventMilestone class]]){
        STAssertEqualObjects([event baseUrlPath], @"milestone", @"Has correct URL Path");
    } else if([event isKindOfClass:[PNEventUserInfo class]]){
        STAssertEqualObjects([event baseUrlPath], @"userInfo", @"Has correct URL Path");
    }
}

- (void) testAppRunning{
    int touches = 1;
    int totalTouches = 10;
    int sequence = 2;

    int keyPressed = 0;
    int totalKeysPressed = 0;
    
    NSTimeInterval startTime = [[NSDate new] timeIntervalSince1970];
    
    PNEventAppRunning *running = [[PNEventAppRunning alloc] initWithSessionInfo:_info instanceId:_instanceId sessionStartTime:startTime sequenceNumber:sequence touches:touches totalTouches:totalTouches];
    
    [self assertCommonInfoIsAvailable:running sessionInfo:_info];
    STAssertEqualObjects([running.eventParameters valueForKey:@"i"], [_instanceId toHex], @"Instance ID is set");
    STAssertEqualObjects([running.eventParameters valueForKey:@"c"], [NSNumber numberWithInt:touches], @"Touch events is set");
    STAssertEqualObjects([running.eventParameters valueForKey:@"e"], [NSNumber numberWithInt:totalTouches], @"Total touch events is set");
    STAssertEqualObjects([running.eventParameters valueForKey:@"q"], [NSNumber numberWithInt:sequence], @"Sequence is set");
    STAssertEqualObjects([running.eventParameters valueForKey:@"k"], [NSNumber numberWithInt:keyPressed], @"Keys pressed is set");
    STAssertEqualObjects([running.eventParameters valueForKey:@"l"], [NSNumber numberWithInt:totalKeysPressed], @"Total keys pressed is set");
    STAssertEqualObjects([running.eventParameters valueForKey:@"r"], [NSNumber numberWithLongLong:startTime * 1000], @"Session start time is set");
}

- (void) testAppPause{
    int touches = 1;
    int totalTouches = 10;
    int sequence = 2;
    
    int keyPressed = 0;
    int totalKeysPressed = 0;
    
    NSTimeInterval startTime = [[NSDate new] timeIntervalSince1970];
    
    PNEventAppPause *pause = [[PNEventAppPause alloc] initWithSessionInfo:_info instanceId:_instanceId sessionStartTime:startTime sequenceNumber:sequence touches:touches totalTouches:totalTouches];
    
    [self assertCommonInfoIsAvailable:pause sessionInfo:_info];
    STAssertEqualObjects([pause.eventParameters valueForKey:@"i"], [_instanceId toHex], @"Instance ID is set");
    STAssertEqualObjects([pause.eventParameters valueForKey:@"c"], [NSNumber numberWithInt:touches], @"Touch events is set");
    STAssertEqualObjects([pause.eventParameters valueForKey:@"e"], [NSNumber numberWithInt:totalTouches], @"Total touch events is set");
    STAssertEqualObjects([pause.eventParameters valueForKey:@"q"], [NSNumber numberWithInt:sequence], @"Sequence is set");
    STAssertEqualObjects([pause.eventParameters valueForKey:@"k"], [NSNumber numberWithInt:keyPressed], @"Keys pressed is set");
    STAssertEqualObjects([pause.eventParameters valueForKey:@"l"], [NSNumber numberWithInt:totalKeysPressed], @"Total keys pressed is set");
    STAssertEqualObjects([pause.eventParameters valueForKey:@"r"], [NSNumber numberWithLongLong:startTime * 1000], @"Session start time is set");
}

- (void) testAppResume{
    NSTimeInterval startTime = [[NSDate new] timeIntervalSince1970] - 5 * 60;
    NSTimeInterval pauseTime = [[NSDate new] timeIntervalSince1970];
    int sequence = 3;
    PNEventAppResume *resume = [[PNEventAppResume alloc] initWithSessionInfo:_info instanceId:_instanceId sessionPauseTime:pauseTime sessionStartTime:startTime sequenceNumber:sequence];
    [self assertCommonInfoIsAvailable:resume sessionInfo:_info];
    
    STAssertEqualObjects([resume.eventParameters valueForKey:@"i"], [_instanceId toHex], @"Instance ID is set");
    STAssertEqualObjects([resume.eventParameters valueForKey:@"q"], [NSNumber numberWithInt:sequence], @"Sequence is set");
    STAssertEqualObjects([resume.eventParameters valueForKey:@"p"], [NSNumber numberWithLongLong: pauseTime * 1000], @"Pause time is set");
    
}

- (void) testAppStart{
    PNEventAppStart *start = [[PNEventAppStart alloc] initWithSessionInfo:_info instanceId:_instanceId];
    [self assertCommonInfoIsAvailable:start sessionInfo:_info];
    STAssertEqualObjects([start.eventParameters valueForKey:@"i"], [_instanceId toHex], @"Instance ID is set");
    STAssertEqualObjects([start.eventParameters valueForKey:@"z"], [NSNumber numberWithInt:[PNUtil timezoneOffet]], @"Instance ID is set");
}

-(void) testAppPage{
    PNEventAppPage *page = [[PNEventAppPage alloc] initWithSessionInfo:_info instanceId:_instanceId];
    [self assertCommonInfoIsAvailable:page sessionInfo:_info];
    STAssertEqualObjects([page.eventParameters valueForKey:@"i"], [_instanceId toHex], @"Instance ID is set");
    STAssertEqualObjects([page.eventParameters valueForKey:@"z"], [NSNumber numberWithInt:[PNUtil timezoneOffet]], @"Instance ID is set");
}

- (void) testTransaction{
    
    NSNumber * quantity = [NSNumber numberWithInt: 1];
    NSNumber * price = [NSNumber numberWithInt: 10];
    
    NSArray *currencyTypes = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:PNCurrencyUSD], nil];
    NSArray *currencyValues = [[NSArray alloc] initWithObjects:price, nil];
    NSArray *currencyCategories = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:PNCurrencyCategoryReal], nil];
    
    PNEventTransaction *trans = [[PNEventTransaction alloc] initWithSessionInfo:_info itemId:@"item" quantity: [quantity intValue] type:PNTransactionBuyItem currencyTypes:currencyTypes currencyValues:currencyValues currencyCategories:currencyCategories];

    [self assertCommonInfoIsAvailable:trans sessionInfo:_info];
    STAssertEqualObjects([trans.eventParameters valueForKey:@"tc0"], @"USD", @"Currency type is set");
    STAssertEqualObjects([trans.eventParameters valueForKey:@"tv0"], [NSNumber numberWithInt:10], @"Currency value is set");
    STAssertEqualObjects([trans.eventParameters valueForKey:@"ta0"], @"r", @"Currency category is set");
    
    STAssertNotNil([trans.eventParameters valueForKey:@"r"], @"Transaction ID is set");
    STAssertEqualObjects([trans.eventParameters valueForKey:@"tt"], @"BuyItem", @"Transaction Type is set");
    STAssertEqualObjects([trans.eventParameters valueForKey:@"tq"], quantity, @"Quantity is set");
    STAssertEqualObjects([trans.eventParameters valueForKey:@"i"], @"item", @"Item is set");
}

- (void) testMilestone{
    PNEventMilestone *milestone = [[PNEventMilestone alloc] initWithSessionInfo:_info milestoneType:PNMilestoneCustom9];
    
    [self assertCommonInfoIsAvailable:milestone sessionInfo:_info];
    STAssertNotNil([milestone.eventParameters valueForKey:@"mi"], @"Transaction ID is set");
    STAssertEqualObjects([milestone.eventParameters valueForKey:@"mn"], @"CUSTOM9", @"Milestone 9 is set");
}

- (void) testUserInfo{
    
}

@end
