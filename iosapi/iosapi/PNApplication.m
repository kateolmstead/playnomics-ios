//
//  PNApplication.m
//  iosapi
//
//  Created by Martin Harkins on 6/27/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PNErrorEvent.h"
#import "PlaynomicsSession.h"
#import "PlaynomicsSession+Exposed.h"

@implementation PNApplication
- (void) sendEvent: (UIEvent *) event {
    
    NSLog(@"sendEvent: %@", event.description);
    
    if (event.type == UIEventTypeTouches) {
        UITouch *touch = [event allTouches].anyObject;
        if (touch.phase == UITouchPhaseBegan) {
            NSLog(@"sendEvent: PN touch event detected");
            [[PlaynomicsSession sharedInstance] onTouchDown: event];
        }
    }
    [super sendEvent:event];
}
@end
