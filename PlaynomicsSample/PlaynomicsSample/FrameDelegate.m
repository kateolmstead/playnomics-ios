//
//  UIFrameDelegate.m
//  PlaynomicsSample
//
//  Created by Jared Jenkins on 7/29/13.
//  Copyright (c) 2013 Grio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FrameDelegate.h"

@implementation FrameDelegate

-(void) onTouch:(NSDictionary *)jsonData{
    NSLog(@"Touch was received for frame");
}

-(void) onClose:(NSDictionary *)jsonData{
    NSLog(@"Close was received for frame.");
}

-(void) onDidFailToRender{
    NSLog(@"Did fail to render.");
}

-(void) onShow:(NSDictionary *)jsonData{
    NSLog(@"Did show for frame.");
}

@end
