//
//  PNUtilTests.h
//  iosapi
//
//  Created by Jared Jenkins on 8/27/13.
//
//

#import <SenTestingKit/SenTestingKit.h>

@interface PNUtilTests : SenTestCase

-(void) testIsUrlShouldHandleNil;
-(void) testIsUrlShouldAcceptHttp;
-(void) testIsUrlShouldAcceptHttps;
-(void) testIsUrlShouldNegateNonUrl;

-(void) testBoolAsString;
-(void) testStringAsBool;

@end
