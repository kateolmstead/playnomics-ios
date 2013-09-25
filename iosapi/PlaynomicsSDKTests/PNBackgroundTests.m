//
//  PNBackgroundTests.m
//  PlaynomicsSDK
//
//  Created by Jared Jenkins on 9/24/13.
//
//

#import <XCTest/XCTest.h>
#import "PNUtil.h"
#import "PNAdData.h"

@interface PNBackgroundTests : XCTest

@end

@implementation PNBackgroundTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testDimensions{
    
    id mock = [OCMockObject mockForClass:[PNUtil class]];
    
    PNBackground *background = [[PNBackground alloc] init];
    background.landscapeDimensions = CGRectMake(0, 10, 20, 20);
    background.portraitDimensions = CGRectMake(10, 0, 20, 20);


    [[[mock stub] andReturn:OCMOCK_VALUE(UIInterfaceOrientationLandscapeLeft)] getCurrentOrientation];
    XCTAssertEqualObjects(background.landscapeDimensions, [background dimensionsForCurrentOrientation], @"Landcape dimensions should be returned.");
    
    [[[mock stub] andReturn:UIInterfaceOrientationLandscapeRight] getCurrentOrientation];
    XCTAssertEqualObjects(background.landscapeDimensions, [background dimensionsForCurrentOrientation], @"Landcape dimensions should be returned.");
    
    [[[mock stub] andReturn:UIInterfaceOrientationPortraitUpsideDown] getCurrentOrientation];
    XCTAssertEqualObjects(background.portraitDimensions, [background dimensionsForCurrentOrientation], @"Portrait dimensions should be returned.");
    
    [[[mock stub] andReturn:UIInterfaceOrientationPortrait] getCurrentOrientation];
    XCTAssertEqualObjects(background.portraitDimensions, [background dimensionsForCurrentOrientation], @"Portrait dimensions should be returned.");
    [background release];
}

@end
