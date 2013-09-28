//
//  PnFrameTests.m
//  PlaynomicsSDK
//
//  Created by Jared Jenkins on 9/18/13.
//
//

#import <XCTest/XCTest.h>

@interface PNFrameTests : XCTestCase

@end

@implementation PNFrameTests

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


-(void) testWebViewCreated
{
    //given some FrameResponse for a WebView is sent, the adView of the frame is a PNWebView
}

-(void) testImageViewCreated
{
    //given some FrameResponse for an ImageView is sent, the adView of the frame is an PNImageView
}

@end
