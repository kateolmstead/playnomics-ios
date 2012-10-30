//
//  AppDelegate.m
//  PlaynomicsSample
//
//  Created by Martin Harkins on 6/27/12.
//  Copyright (c) 2012 Grio. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"


@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    long appId = 3L;
    NSString *userId = @"SampleUserId1234";
    [PlaynomicsSession setTestMode:YES];
    [PlaynomicsSession startWithApplicationId:appId userId:userId];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil] autorelease];
    } else {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil] autorelease];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];



    // Grab the shared (singleton) instance of the messaging class
    PlaynomicsMessaging *messaging = [PlaynomicsMessaging sharedInstance];

    // Register an action handler bound to the provided label.  You can set as many handlers as you want, as long
    //   they are registered with unique names
    [messaging registerActionHandler:self withLabel:@"test_action"];

    // Set the delegate that execution targets will be called against.
//    messaging.delegate = self;

    // Retrieve the ad frame you need using the provided Frame ID and start it.  Once all of the assets are loaded
    //   the frame will display itself.
    PlaynomicsFrame *frame = [messaging initFrameWithId:@"some_frame_id"];
    DisplayResult result = [frame start];
    NSLog(@"Result of calling start: %i", result);
    return YES;
}


- (void)performAction {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test Action"
                                                    message:@"You're performing a test ACTION.  Did I mention that Julio is AWESOME!"
                                                   delegate:self
                                          cancelButtonTitle:@"I Agree!"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)someRandomExecution {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test Executiong"
                                                    message:@"You're performing a test EXECUTION.  Did I mention that Julio is AWESOME!"
                                                   delegate:self
                                          cancelButtonTitle:@"He is!"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];

    // @throw [NSException exceptionWithName:@"Test Exception" reason:@"Oopps...I was a bad boy" userInfo:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
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
