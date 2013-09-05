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


- (void)onClick:(NSDictionary *)jsonData{
    NSString* message = [NSString stringWithFormat: @"Data for frame %@" , jsonData];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"JSON Callback"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void)webView: (UIWebView*) webView shouldStartLoadWithRequest: (NSURLRequest *) request navigationType: (UIWebViewNavigationType) navigationType {
    NSLog(@"Navigation Type = %d", navigationType);
    NSURL *URL = [request URL];
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSLog(@"Web View was clicked and URL is %@", URL);
    }
}
@end
