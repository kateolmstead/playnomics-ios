//
//  iosapiTests.m
//  iosapiTests
//
//  Created by Douglas Kadlecek on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iosapiTests.h"
#import "EventSender.h"
#import "BasicEvent.h"
#import "SocialEvent.h"
#import "TransactionEvent.h"
#import "UserInfoEvent.h"
#import "RandomGenerator.h"

@implementation iosapiTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void) testRandomGenerator {
    for (int i = 0; i < 1000; i ++) {
        NSString *hex = [RandomGenerator createRandomHex];
        STAssertTrue([hex length] == 16, @"hex:%@ length (%d) must be equal to 16", hex, [hex length]);
        
        for (int i = 0; i < [hex length]; i++) {
            char c = [hex characterAtIndex:i];
            STAssertTrue('a' <= c && c <= 'f' || '0' <= c && c <= '9' || c == ',' || c == ':', @"hex:%@ c:'%c' not a HEX", hex, c);
        }
    }
}

//- (void)testEvents
//{
//    EventSender *es = [[EventSender alloc] initWithTestMode:YES];
//    NSMutableArray *el = [NSMutableArray array];
//    
//    long applicationId = 4L;
//    NSString *userId = @"userIdTest";
//    [[el addObject:[BasicEvent alloc] init:PLEventAppStart applicationId:4L userId:userId cookieId:<#(NSString *)#> sessionId:<#(NSString *)#> instanceId:<#(NSString *)#> timeZoneOffset:<#(int)#>]];
//}

@end
