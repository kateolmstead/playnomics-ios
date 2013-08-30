//
//  PNEventTests.h
//  iosapi
//
//  Created by Jared Jenkins on 8/30/13.
//
//

#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

@interface PNEventTests : SenTestCase
- (void) testAppRunning;
- (void) testAppPause;
- (void) testAppResume;
- (void) testAppStart;
- (void) testTransaction;
- (void) testMilestone;
- (void) testUserInfo;
@end
