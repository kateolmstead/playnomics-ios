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
        _generatedId = [self generateNewId];
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

-(long long) generateNewId{
    uint8_t buffer[8];
    arc4random_buf(buffer, sizeof buffer);
    uint64_t* value_ptr = (uint64_t*) buffer;
    return *value_ptr;
}

@end
