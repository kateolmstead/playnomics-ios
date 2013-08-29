//
//  PNGeneratedHexId.m
//  iosapi
//
//  Created by Jared Jenkins on 8/27/13.
//
//

#import "PNGeneratedHexId.h"

@implementation PNGeneratedHexId

@synthesize generatedId=_generatedId;

- (id) initAndGenerateValue{
    if((self = [super init])){
        _generatedId = [PNUtil generateRandomLongLong];
    }
    return self;
}

- (id) initWithValue: (NSString*) value{
    if((self = [super init])){
        //parse a hex-based representation of the number to long long
        _generatedId = strtoll([value UTF8String], NULL, 16);
    }
    return self;
}

-(NSString *) description{
    return [self toHex];
}

-(NSString *) toHex{
    return [NSString stringWithFormat:@"%llX", _generatedId];
}


@end
