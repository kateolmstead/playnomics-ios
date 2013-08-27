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
    STAssertEquals(value, NO, @"Nil string should return FALSE");
}
-(void) testIsUrlShouldAcceptHttp{
    BOOL value = [PNUtil isUrl:@"http://google.com"];
    STAssertEquals(value, YES, @"http protocol should return TRUE");
}

-(void) testIsUrlShouldAcceptHttps{
    BOOL value = [PNUtil isUrl:@"https://facebook.com"];
    STAssertEquals(value, YES, @"https protocol should return TRUE");
}

-(void) testIsUrlShouldNegateNonUrl{
    BOOL value = [PNUtil isUrl:@"test"];
    STAssertEquals(value, NO, @"'test' is not a valid URL");
}

-(void) testBoolAsString{
    STAssertEquals([PNUtil boolAsString:YES], @"true", @"TRUE should return 'true'");
    STAssertEquals([PNUtil boolAsString:NO], @"false", @"FALSE should return 'false'");
}

-(void) testStringAsBool{
    STAssertEquals([PNUtil stringAsBool: @"true"], YES, @"String 'true' should return TRUE");
    STAssertEquals([PNUtil stringAsBool: @"TRUE"], YES, @"String 'TRUE' should return TRUE");
    STAssertEquals([PNUtil stringAsBool: @"false"], NO, @"String 'false' should return FALSE");
    STAssertEquals([PNUtil stringAsBool: @"FALSE"], NO, @"String 'False' should return FALSE");
    STAssertEquals([PNUtil stringAsBool: nil], NO, @"String nil should return FALSE");
    STAssertEquals([PNUtil stringAsBool: @"test"], NO, @"String 'test' should return FALSE");
}
@end
