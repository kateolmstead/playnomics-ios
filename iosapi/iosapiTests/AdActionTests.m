//
//  AdActionTests.m
//  iosapi
//
//  Created by Eric McConkie on 1/22/13.
//
//

#import "AdActionTests.h"
#import "PNActionObjects.h"

@implementation AdActionTests
#pragma mark -
#pragma mark ad action type
- (void) testGetURLTYPEPNX
{
    NSString *clickTarget = @"pnx://[NSThread sleepForTimeIntervalL:5.0]";
    
    AdAction action = [PNActionObjects adActionTypeForURL:clickTarget];
    STAssertTrue(action == AdActionExecuteCode, @"should be pnx");
    
}

- (void) testGetURLTYPEPNA
{
    NSString *clickTarget = @"pna://showBox();";
    
    AdAction action = [PNActionObjects adActionTypeForURL:clickTarget];
    STAssertTrue(action == AdActionDefinedAction, @"should be pna");
    
}

- (void) testGetURLTYPEHTTP
{
    NSString *clickTarget = @"http://www.google.com";
    
    AdAction action = [PNActionObjects adActionTypeForURL:clickTarget];
    STAssertTrue(action == AdActionHTTP, @"should be http");
    
}

- (void) testGetURLTYPEGarbage
{
    NSString *clickTarget = @"ftp://www.google.com";
    
    AdAction action = [PNActionObjects adActionTypeForURL:clickTarget];
    STAssertTrue(action == AdActionUnknown, @"should be unknown");
    
}
#pragma mark -
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
