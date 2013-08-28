//
//  PNGeneratedHexIdTests.m
//  iosapi
//
//  Created by Jared Jenkins on 8/27/13.
//
//

#import "PNGeneratedHexIdTests.h"
#import "PNGeneratedHexId.h"

@implementation PNGeneratedHexIdTests

-(void) testGeneratesSessionId{
    PNGeneratedHexId *genId = [[PNGeneratedHexId alloc] initAndGenerateValue];
    STAssertTrue(genId.generatedId > 0, @"Generated ID must be greater than 0");
    
    NSString* hexString = [genId description];
    
    PNGeneratedHexId *cloneGenId = [[PNGeneratedHexId alloc] initWithValue: hexString];

    STAssertEquals(genId.generatedId, cloneGenId.generatedId, @"Generated ID should be parsed from it's HEX represention.");
}

@end
