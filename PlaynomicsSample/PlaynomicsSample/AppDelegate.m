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

-(void)onPushAlert:(NSDictionary*)userInfo
{
//    NSString *noteId = [NSString stringWithFormat:@"Push ID: %@",
//                        [userInfo valueForKeyPath:@"push_id"]];
//    NSString *notemessage = [NSString stringWithFormat:@"%@",
//                             [userInfo valueForKeyPath:@"push_message"]];
//    
//    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:noteId
//                                                     message:notemessage
//                                                    delegate:nil cancelButtonTitle:@"Yup" otherButtonTitles: nil] autorelease];
//    [alert show];
}

#pragma mark -
#pragma mark push notifications

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"device token found\r\nsend to playnomics\r\n---> %@",deviceToken);

    [PlaynomicsSession enablePushNotificationsWithToken:deviceToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    
}
-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PlaynomicsSession pushNotificationsWithPayload:userInfo];
    
    //demonstates we got the push
    [self performSelector:@selector(onPushAlert:) withObject:userInfo afterDelay:0.6];
}

#pragma mark -
#pragma mark launch
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    long appId = 3L;
    NSString *userId = @"SampleUserId1234";
    [PlaynomicsSession setTestMode:YES];
    [PlaynomicsSession startWithApplicationId:appId userId:userId];
    

    //enable notifications
    UIApplication *app = [UIApplication sharedApplication];
    UIRemoteNotificationType types = [app enabledRemoteNotificationTypes];
    if (types<=0) {
        
        // we could forego the check for "types" and always "registerForRemoteNotifications" on launch,
        // however, this way prevents us from calling the notificaion url from the api lib N times
        
        // register for notifications
        [app registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
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
