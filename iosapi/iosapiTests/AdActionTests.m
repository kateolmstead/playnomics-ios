//
//  AdActionTests.m
//  iosapi
//
//  Created by Eric McConkie on 1/22/13.
//
//

#import "AdActionTests.h"
@implementation AdActionTests
#pragma mark test pnx
-(void) onPNXSuccess
{
    self.isDone = YES;
    STAssertTrue(1==1, @"not working");
}
-(void) testPNXMessaging
{
    self.isDone = NO;
    // Do any additional setup after loading the view, typically from a nib.
    // Grab the shared (singleton) instance of the messaging class
    PlaynomicsMessaging *messaging = [PlaynomicsMessaging sharedInstance];
    messaging.isTesting = YES;
    // Register an action handler bound to the provided label.  You can set as many handlers as you want, as long
    //   they are registered with unique names
    [messaging registerActionHandler:self withLabel:@"test_action"];
    
    // Set the delegate that execution targets will be called against.
    messaging.delegate = self;
    
    NSDictionary *dict = [messaging _retrieveFramePropertiesForId:@"whatever" withCaller:@"test"];
    PlaynomicsFrame *frame = [[PlaynomicsFrame alloc] initWithProperties:dict forFrameId:@"whatever" andDelegate:self];
    [frame start];
    while (!self.isDone) {
        //...wait
    }
    
}



@end
