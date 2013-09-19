//
//  PNEventApiClientTests.m
//  iosapi
//
//  Created by Jared Jenkins on 9/5/13.
//
//

#import "PNEventApiClient.h"
#import <XCTest/XCTest.h>

@interface PNEventApiClientTests : XCTestCase

@end

@implementation PNEventApiClientTests

-(void) setup {
    [super setUp];
}

-(void) tearDown {
    [super tearDown];
}

-(void) testNilUrl{
    NSString* url = [PNEventApiClient buildUrlWithBase:nil withPath: nil withParams:nil];
    XCTAssertNil(url, @"url should be nil");
}

-(void) testUrlWithNoPath{
    NSString* url = [PNEventApiClient buildUrlWithBase:@"http://google.com" withPath: nil withParams:nil];
    XCTAssertEqualObjects(url, @"http://google.com", @"URL is set");
}

-(void) testUrlWithBasePath{
    NSString* url = [PNEventApiClient buildUrlWithBase:@"http://google.com" withPath: @"path" withParams:nil];
    XCTAssertEqualObjects(url, @"http://google.com/path", @"URL is set");
}

-(void) testUrlWithParamsNoPath{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"10" forKey:@"x"];
    [params setObject:@"100" forKey:@"y"];
    
    NSString* url = [PNEventApiClient buildUrlWithBase:@"http://google.com" withPath: nil withParams:params];
    XCTAssertEqualObjects(url, @"http://google.com?x=10&y=100", @"URL is set");
}

-(void) testUrlWithParamsAndPath{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"10" forKey:@"x"];
    [params setObject:@"100" forKey:@"y"];
    
    NSString* url = [PNEventApiClient buildUrlWithBase:@"http://google.com" withPath: @"path" withParams:params];
    XCTAssertEqualObjects(url, @"http://google.com/path?x=10&y=100", @"URL is set");
}

-(void) testUrlWithParamsAndQueryStringPath{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"10" forKey:@"x"];
    [params setObject:@"100" forKey:@"y"];
    
    NSString* url = [PNEventApiClient buildUrlWithBase:@"http://google.com" withPath: @"?type=path" withParams:params];
    XCTAssertEqualObjects(url, @"http://google.com/?type=path&x=10&y=100", @"URL is set");
}


@end
