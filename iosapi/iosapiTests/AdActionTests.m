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





@end
