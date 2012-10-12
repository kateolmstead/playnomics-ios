//
//  AppDelegate.h
//  PlaynomicsSample
//
//  Created by Martin Harkins on 6/27/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaynomicsMessaging.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, PNAdClickActionHandler>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
