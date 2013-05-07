    //
//  AppDelegate.m
//  PlaynomicsSample
//
//  Created by Martin Harkins on 6/27/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "PlaynomicsSession.h"
@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}
#pragma mark -
#pragma mark private handlers



#pragma mark -
#pragma mark push notifications

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"device token found\r\n---> %@",deviceToken);

    [PlaynomicsSession enablePushNotificationsWithToken:deviceToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"FAILED TO CAPTURE DEVICE TOKEN\r\nERROR STATES:\r\n%@ ",error);
}

-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // we need to distinguish the difference of a user responding to push
    // vs if we receive a push while the app is running.
    UIApplicationState *state = [[UIApplication sharedApplication] applicationState];
    if (state!=UIApplicationStateActive) {
        NSLog(@"sending impression from didReceiveRemoteNotification\r\n---> %@",userInfo);
        // parse the impression url and ping it....
        [PlaynomicsSession pushNotificationsWithPayload:userInfo];
        
    }
}

#pragma mark -
#pragma mark launch
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    long appId = 2L;
    //use a real user id for now
    //NSString *userId = @"SampleUserId1234";
    [PlaynomicsSession setTestMode:NO];
    [PlaynomicsSession startWithApplicationId:appId];
    
    //enable notifications
    UIApplication *app = [UIApplication sharedApplication];
    
   
    [app registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    
    NSDictionary *apn =
    [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (apn) {
        // we need to distinguish the difference of a user responding to push
        // vs if we receive a push while the app is running.
        UIApplicationState *state = [[UIApplication sharedApplication] applicationState];
        if (state!=UIApplicationStateActive) {
             NSLog(@"sending impression from didFinishLaunchingWithOptions\r\n---> %@",apn);
            // parse the impression url and ping it....
            [PlaynomicsSession pushNotificationsWithPayload:apn];
            
        }
    }
    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil] autorelease];
    } else {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil] autorelease];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
