//
//  PNFrameResponseTests.m
//  PlaynomicsSDK
//
//  Created by Jared Jenkins on 9/24/13.
//
//

#import <XCTest/XCTest.h>
#import "PNFrameResponse.h"

typedef enum{
    FrameResponseEmpty,
    FrameResponseFullscreenInternalTargetUrl,
    FrameResponseFullscreenInternalTargetData,
    FrameResponseFullscreenInternalNullTarget,
    FrameResponseThirdPartyHtmlClose,
    FrameResponseThirdPartyNativeClose,
    FrameResponseAdvancedInternal
}FrameResponseType;

@interface PNFrameResponseTests : XCTestCase
@end

@implementation PNFrameResponseTests{
    NSDictionary *_response;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(NSDictionary *) generateFrameResponse: (FrameResponseType) responseType{
    NSMutableDictionary * response = [[NSMutableDictionary alloc]init];
    //m is always nil
    [response setValue:[NSNull null] forKey:@"m"];
    //the expiration time at this point is still constant
    [response setValue:[NSNumber numberWithInt:3600] forKey:@"e"];
    //status is Ok
    [response setValue:@"Ok" forKey:@"s"];
    
    NSMutableArray *ads = [[NSMutableArray alloc]init];
    NSMutableDictionary *ad =  nil;
    NSMutableDictionary *background = nil;
    NSMutableDictionary *closeButton = nil;
    NSMutableDictionary *location = nil;
    
    
    if(responseType == FrameResponseAdvancedInternal){
        ad = [[NSMutableDictionary alloc] init];
        [ad setObject:[NSNumber numberWithInt:0] forKey:@"fullscreen"];
        [ad setObject:@"http://closeUrl" forKey:@"d"];
        [ad setObject:[NSNull null] forKey:@"clickLink"];
        [ad setObject:@"http://imageUrl" forKey:@"i"];
        [ad setObject:@"http://targetUrl" forKey:@"targetURL"];
        [ad setObject:@"native" forKey:@"closeButtonType"];
        [ad setObject:@"image" forKey:@"adType"];
        [ad setObject:[NSNull null] forKey:@"closeButtonLink"];
        [ad setObject:@"http://impressionUrl" forKey:@"s"];
        [ad setObject:@"http://clickUrl" forKey:@"t"];
        
        //background settings
        background = [[NSMutableDictionary alloc] init];
        [background setObject:[NSNull null] forKey:@"i"];
        [background setObject:[NSNumber numberWithFloat:250] forKey:@"h"];
        [background setObject:[NSNumber numberWithFloat:300] forKey:@"w"];
        [background setObject:@"detect" forKey:@"o"];
        
        NSMutableDictionary *landscape = [[NSMutableDictionary alloc] init];
        [landscape setObject:[NSNumber numberWithFloat:352] forKey:@"x"];
        [landscape setObject:[NSNumber numberWithFloat:259] forKey:@"y"];
        [background setObject:landscape forKey:@"l"];
        
        NSMutableDictionary *portrait = [[NSMutableDictionary alloc] init];
        [portrait setObject:[NSNumber numberWithFloat:234] forKey:@"x"];
        [portrait setObject:[NSNumber numberWithFloat:377] forKey:@"y"];
        [background setObject:portrait forKey:@"p"];
        
        //close button settings
        closeButton =  [[NSMutableDictionary alloc] init];
        [closeButton setObject:@"http://closeButtonImage" forKey:@"i"];
        [closeButton setObject:[NSNumber numberWithFloat:270] forKey:@"x"];
        [closeButton setObject:[NSNumber numberWithFloat:0] forKey:@"y"];
        [closeButton setObject:[NSNumber numberWithFloat:30] forKey:@"h"];
        [closeButton setObject:[NSNumber numberWithFloat:30] forKey:@"w"];
        //location settings for the ad
        location = [[NSMutableDictionary alloc] init];
        [closeButton setObject:[NSNumber numberWithFloat:0] forKey:@"x"];
        [closeButton setObject:[NSNumber numberWithFloat:0] forKey:@"y"];
        [closeButton setObject:[NSNumber numberWithFloat:250] forKey:@"h"];
        [closeButton setObject:[NSNumber numberWithFloat:300] forKey:@"w"];
        
    } else if (responseType == FrameResponseFullscreenInternalTargetUrl ||
               responseType == FrameResponseFullscreenInternalTargetData ||
               responseType == FrameResponseFullscreenInternalNullTarget){
        
        
        ad = [[NSMutableDictionary alloc] init];
        [ad setObject:[NSNumber numberWithInt:1] forKey:@"fullscreen"];
        [ad setObject:@"http://closeUrl" forKey:@"d"];
        [ad setObject:@"pn://clickLink" forKey:@"clickLink"];
        
        
        [ad setObject:@"<html></html>" forKey:@"htmlContent"];
        
        [ad setObject:@"http://impressionUrl" forKey:@"s"];
        [ad setObject:@"http://clickUrl" forKey:@"t"];
        [ad setObject:@"html" forKey:@"closeButtonType"];
        [ad setObject:@"html" forKey:@"adType"];
        [ad setObject:@"pn://close" forKey:@"closeButtonLink"];
    
        if(responseType == FrameResponseFullscreenInternalTargetUrl){
            [ad setObject:@"http://targetUrl" forKey:@"targetURL"];
            [ad setObject:@"url" forKey:@"targetType"];
        } else if (responseType == FrameResponseFullscreenInternalTargetData){
            [ad setObject:@"{\"data\":\"test\"}" forKey:@"targetData"];
            [ad setObject:@"data" forKey:@"targetType"];
        } else if (responseType == FrameResponseFullscreenInternalNullTarget){
            [ad setObject:[NSNull null] forKey:@"targetUrl"];
            [ad setObject:@"url" forKey:@"targetType"];
        }
    } else if (responseType == FrameResponseThirdPartyHtmlClose || responseType == FrameResponseThirdPartyNativeClose){
        
        ad = [[NSMutableDictionary alloc] init];
        [ad setObject:[NSNumber numberWithInt:1] forKey:@"fullscreen"];
        [ad setObject:@"<html>third party ad - $$$</html>" forKey:@"htmlContent"];
        [ad setObject:[NSNull null] forKey:@"clickLink"];
        [ad setObject:@"provider" forKey:@"adProvider"];
        [ad setObject:@"external" forKey:@"targetType"];
        [ad setObject:@"http://impressionUrl" forKey:@"s"];
        [ad setObject:@"http://closeUrl" forKey:@"d"];
        
        if(responseType == FrameResponseThirdPartyNativeClose){
            [ad setObject:@"native" forKey:@"closeButtonType"];
            [ad setObject:[NSNull null] forKey:@"clickLink"];
            
            closeButton =  [[NSMutableDictionary alloc] init];
            [closeButton setObject:@"http://closeImage" forKey:@"i"];
            [closeButton setObject:[NSNumber numberWithFloat:26] forKey:@"h"];
            [closeButton setObject:[NSNumber numberWithFloat:26] forKey:@"w"];
        } else {
            [ad setObject:@"html" forKey:@"closeButtonType"];
            [ad setObject:@"thirdParty://close" forKey:@"clickLink"];
        }
    }
    
    if(ad){
        [ads addObject:ad];
    }
    
    if(background){
        [response setObject:background forKey:@"b"];
    }
    
    if(closeButton){
        [response setObject:closeButton forKey:@"c"];
    }
    
    if(location){
        [response setObject:location forKey:@"l"];
    }
    
    [response setObject:ads forKey:@"a"];
    return response;
}

-(void) assertFullscreenInternalAdWithType: (FrameResponseType) responseType {
    
    NSDictionary * response = [self generateFrameResponse:responseType];
    
    NSError *error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:&error];
    
    XCTAssertNil(error, @"Test data was serialized properly");
    
    PNFrameResponse *frame = [[PNFrameResponse alloc] initWithJSONData:jsonData];
    
    XCTAssertNil(frame.background, @"The background should be nil");
    
    XCTAssertTrue([frame.ad isKindOfClass:[PNHtmlAd class]], @"This ad is an HTML ad");
    
    PNHtmlAd *htmlAd = (PNHtmlAd *)frame.ad;
    
    XCTAssertEqualObjects(htmlAd.clickLink, @"pn://clickLink", @"Close link is set up correctly");
    XCTAssertEqualObjects(htmlAd.clickUrl, @"http://clickUrl", @"Click url is set up correctly");
    XCTAssertEqualObjects(htmlAd.closeUrl, @"http://closeUrl", @"Close url is set up correctly");
    XCTAssertEqual(htmlAd.fullscreen, YES, @"Html ad is fullscreen");
    XCTAssertEqualObjects(htmlAd.htmlContent, @"<html></html>", @"Click url is set");
    XCTAssertEqualObjects(htmlAd.impressionUrl, @"http://impressionUrl", @"Impression url is set");
   
    XCTAssertTrue([frame.closeButton isKindOfClass:[PNHtmlCloseButton class]], @"This close button is an HTML close button");
    
    PNHtmlCloseButton *closeButton = (PNHtmlCloseButton *)frame.closeButton;
    XCTAssertEqualObjects(closeButton.closeButtonLink, @"pn://close");
    
    
    if(responseType == FrameResponseFullscreenInternalNullTarget){
        XCTAssertEqual(htmlAd.targetType, AdTargetUrl, @"Target type is URL");
        XCTAssertNil(htmlAd.targetUrl, @"Target url is null");
        XCTAssertNil(htmlAd.targetData, @"Target data is null");
    } else if(responseType == FrameResponseFullscreenInternalTargetData) {
        XCTAssertEqual(htmlAd.targetType, AdTargetData, @"Target type is data");
        XCTAssertNil(htmlAd.targetUrl, @"Target url is null");
        
        NSMutableDictionary *targetData = [[NSMutableDictionary alloc] init];
        [targetData setObject:@"test" forKey:@"data"];
        XCTAssertEqualObjects(htmlAd.targetData, targetData, @"Target data is set");
    } else {
        XCTAssertEqual(htmlAd.targetType, AdTargetUrl, @"Target type is URL");
        XCTAssertEqualObjects(htmlAd.targetUrl, @"http://targetUrl", @"Target url is set");
        XCTAssertNil(htmlAd.targetData, @"Target data is null");
    }
}

-(void) testEmptyAdArray{
    NSDictionary * response = [self generateFrameResponse:FrameResponseEmpty];

    NSError *error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:&error];
    
    XCTAssertNil(error, @"Test data was serialized properly");
    
    PNFrameResponse *frame = [[PNFrameResponse alloc] initWithJSONData:jsonData];
    
    XCTAssertNil(frame.background, @"The background should be nil");
    XCTAssertNil(frame.closeButton, @"The close button should be nil");
    XCTAssertNil(frame.ad, @"The ad is nil");
}


-(void) testFullscreenInternalAdTargetUrl{
    [self assertFullscreenInternalAdWithType: FrameResponseFullscreenInternalTargetUrl];
}

-(void) testFullscreenInternalAdTargetData{
    [self assertFullscreenInternalAdWithType: FrameResponseFullscreenInternalTargetData];
}

-(void) testFullscreenInternalAdNullTarget{
    [self assertFullscreenInternalAdWithType: FrameResponseFullscreenInternalNullTarget];
}

-(void) testThirdPartyNativeClose{
    
}

-(void) testThirdPartyHtmlClose{
    
}

-(void) testAdvancedAd{
    
}
@end
