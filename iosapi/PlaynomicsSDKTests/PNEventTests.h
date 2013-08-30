//
//  PNEventTests.h
//  iosapi
//
//  Created by Jared Jenkins on 8/29/13.
//
//

#import <UIKit/UIKit.h>
#import <SenTestingKit/SenTestingKit.h>

@interface PNEventTests : SenTestCase

//runs session start with no initial device data, expects 2 events: appStart and userInfo
-(void) testAppStartNewDevice;
//runs session start with initial device data, expects 1 event: appStart
-(void) testAppStartNoDeviceChanges;

//runs session start with no initial device data, a previous startTime, expects 2 events: appPage and userInfo
-(void) testAppPauseNewDevice;
//runs session start with initial device data, a previous startTime, expects 2 events: appPage
-(void) testAppPauseNoDeviceChanges;

//runs the start, and then milestone. expects 2 events: appStart and milestone
-(void) testMilestone;
//runs the milestone without calling start first. expects 0 events
-(void) testMilestoneNoStart;

//runs start, and then transaction. expects 2 events: appStart and milestone
-(void) testTransaction;
//runs  transaction without calling start first. expects 0 events
-(void) testTransactionNoStart;

//runs start, and then enablePushNotifications, expects 2 events: appStart and enable push notifications
-(void) testEnabledPushNotifications;
//runs enablePushNotifications without calling start first. expects 0 events
-(void) testEnabledPushNoStart;


@end
