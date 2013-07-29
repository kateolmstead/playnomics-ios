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

NSString* _frameId;

-(id)initWithFrameId:(NSString*) frameId {    
    _frameId = frameId;
    self =[super init];
    return self;
}

- (void)onClick:(NSDictionary *)jsonData{
    NSString* message = [NSString stringWithFormat: @"Data for frame %@ %@", _frameId, jsonData];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"JSON Callback"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}
@end
