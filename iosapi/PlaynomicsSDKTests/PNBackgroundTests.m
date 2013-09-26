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

@interface PNBackgroundTests : XCTestCase

@end

@implementation PNBackgroundTests{
    PNBackground *_background;
    id _mock;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _background = [[PNBackground alloc] init];
    _background.landscapeDimensions = CGRectMake(0, 10, 20, 20);
    _background.portraitDimensions = CGRectMake(10, 0, 20, 20);
    
    _mock = [OCMockObject mockForClass:[PNUtil class]];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [_background release];
    [_mock stopMocking];
}

-(void) testDimensionsLandscapeLeft{
    UIInterfaceOrientation left = UIInterfaceOrientationLandscapeLeft;
    NSValue *leftValue = [NSValue value:&left withObjCType:@encode(__typeof__(left))];
    [[[_mock stub] andReturnValue:leftValue] getCurrentOrientation];
    XCTAssertEqual(_background.landscapeDimensions, [_background dimensionsForCurrentOrientation], @"Landcape dimensions should be returned.");
}

-(void) testDimensionsLandscapeRight{
    UIInterfaceOrientation right = UIInterfaceOrientationLandscapeLeft;
    NSValue *rightValue = [NSValue value:&right withObjCType:@encode(__typeof__(right))];
    [[[_mock stub] andReturnValue:rightValue] getCurrentOrientation];
    XCTAssertEqual(_background.landscapeDimensions, [_background dimensionsForCurrentOrientation], @"Landcape dimensions should be returned.");
}

-(void) testDimensionsPortrait{
    UIInterfaceOrientation portrait = UIInterfaceOrientationPortrait;
    NSValue *portraitValue = [NSValue value:&portrait withObjCType:@encode(__typeof__(portrait))];
    [[[_mock stub] andReturnValue:portraitValue] getCurrentOrientation];
    XCTAssertEqual(_background.portraitDimensions, [_background dimensionsForCurrentOrientation], @"Portrait dimensions should be returned.");
}

-(void) testDimensionsPortraitUpsideDown{
    UIInterfaceOrientation portraitUpsideDown = UIInterfaceOrientationPortraitUpsideDown;
    NSValue *portraitUpsideDownValue = [NSValue value:&portraitUpsideDown withObjCType:@encode(__typeof__(portraitUpsideDown))];
    [[[_mock stub] andReturnValue:portraitUpsideDownValue] getCurrentOrientation];
    XCTAssertEqual(_background.portraitDimensions, [_background dimensionsForCurrentOrientation], @"Portrait dimensions should be returned.");

}

@end
