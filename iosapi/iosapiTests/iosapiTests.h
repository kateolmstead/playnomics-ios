//
//  iosapiTests.h
//  iosapiTests
//
//  Created by Douglas Kadlecek on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "EventSender.h"
#import "PlaynomicsSession.h"

@interface iosapiTests : SenTestCase {
    NSArray *v;
    EventSender *eventSender;
    
    PlaynomicsSession *s;
}

- (void) testSendingEvents: (NSArray *) events;

- (void) sendClickEvent;
- (void) sendKeyEvent;
- (void) sendSleepAwakeEvents;
- (void) sendCloseEvent;
- (void) triggerTimer;
@end
