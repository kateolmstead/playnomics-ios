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
    
    if(jsonData){
        NSString* message = [NSString stringWithFormat: @"Click data for frame %@" , jsonData];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"JSON Callback"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

-(void) onClose:(NSDictionary *)jsonData{
    NSLog(@"Close was received for frame.");
    if(jsonData){
        NSString* message = [NSString stringWithFormat: @"Close data for frame %@" , jsonData];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"JSON Callback"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        NSLog(@" JSON data is %@ ", jsonData);
    }
}

-(void) onDidFailToRender:(NSDictionary *)jsonData{
    NSLog(@"Did fail to render.");
    NSString* message = [NSString stringWithFormat: @"Could not render the frame %@" , jsonData];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"JSON Callback"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
}

-(void) onShow:(NSDictionary *)jsonData{
    NSLog(@"Did show for frame.");
    if(jsonData){
        NSString* message = [NSString stringWithFormat: @"Impression data for frame %@" , jsonData];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"JSON Callback"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        NSLog(@" JSON data is %@ ", jsonData);
    }
}

@end
