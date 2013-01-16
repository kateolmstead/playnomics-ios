//
//  PNApplication.m
//  iosapi
//
//  Created by Martin Harkins on 6/27/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "PlaynomicsSession.h"
#import "PlaynomicsSession+Exposed.h"

@implementation PNApplication

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{

    NSLog(@"device token\r\n---> %@",deviceToken);
    NSLog(@"%d,%s",__LINE__,__FUNCTION__);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    
}
-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"on remote note\r\n---> %@",userInfo);
    NSLog(@"%d,%s",__LINE__,__FUNCTION__);
}

- (void) sendEvent: (UIEvent *) event {
    if (event.type == UIEventTypeTouches) {
        UITouch *touch = [event allTouches].anyObject;
        if (touch.phase == UITouchPhaseBegan) {
            [[PlaynomicsSession sharedInstance] onTouchDown: event];
        }
    }
    [super sendEvent:event];
}
@end
