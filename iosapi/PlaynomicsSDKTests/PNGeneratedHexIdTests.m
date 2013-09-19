//
//  PNGeneratedHexIdTests.m
//  iosapi
//
//  Created by Jared Jenkins on 8/27/13.
//
//

#import "PNGeneratedHexId.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "OCMock.h"
#import "OCMockObject.h"
#import "OCMArg.h"
#import <XCTest/XCTest.h>

@interface PNGeneratedHexIdTests : XCTestCase
@end


@implementation PNGeneratedHexIdTests

-(void) testGeneratesSessionId{
    PNGeneratedHexId *genId = [[PNGeneratedHexId alloc] initAndGenerateValue];
    XCTAssertTrue(genId.generatedId > 0, @"Generated ID must be greater than 0");
    
    NSString* hexString = [genId toHex];
    
    PNGeneratedHexId *cloneGenId = [[PNGeneratedHexId alloc] initWithValue: hexString];

    XCTAssertEqual(genId.generatedId, cloneGenId.generatedId, @"Generated ID should be parsed from it's HEX represention.");
}

-(void) testGeneratesSessionIdMultipleTimes{
    for(int i = 0; i < 1000; i ++){
        [self testGeneratesSessionId];
    }
}
@end
