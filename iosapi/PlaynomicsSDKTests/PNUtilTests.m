//
//  PNUtilTests.m
//  iosapi
//
//  Created by Jared Jenkins on 8/27/13.
//
//

#import "PNUtilTests.h"
#import "PNUtil.h"

@implementation PNUtilTests

-(void) testIsUrlShouldHandleNil{
    BOOL value = [PNUtil isUrl:nil];
    XCTAssertEqual(value, NO, @"Nil string should return FALSE");
}
-(void) testIsUrlShouldAcceptHttp{
    BOOL value = [PNUtil isUrl:@"http://google.com"];
    XCTAssertEqual(value, YES, @"http protocol should return TRUE");
}

-(void) testIsUrlShouldAcceptHttps{
    BOOL value = [PNUtil isUrl:@"https://facebook.com"];
    XCTAssertEqual(value, YES, @"https protocol should return TRUE");
}

-(void) testIsUrlShouldNegateNonUrl{
    BOOL value = [PNUtil isUrl:@"test"];
    XCTAssertEqual(value, NO, @"'test' is not a valid URL");
}

-(void) testBoolAsString{
    XCTAssertEqual([PNUtil boolAsString:YES], @"true", @"TRUE should return 'true'");
    XCTAssertEqual([PNUtil boolAsString:NO], @"false", @"FALSE should return 'false'");
}

-(void) testStringAsBool{
    XCTAssertEqual([PNUtil stringAsBool: @"true"], YES, @"String 'true' should return TRUE");
    XCTAssertEqual([PNUtil stringAsBool: @"TRUE"], YES, @"String 'TRUE' should return TRUE");
    XCTAssertEqual([PNUtil stringAsBool: @"false"], NO, @"String 'false' should return FALSE");
    XCTAssertEqual([PNUtil stringAsBool: @"FALSE"], NO, @"String 'False' should return FALSE");
    XCTAssertEqual([PNUtil stringAsBool: nil], NO, @"String nil should return FALSE");
    XCTAssertEqual([PNUtil stringAsBool: @"test"], NO, @"String 'test' should return FALSE");
}
@end
