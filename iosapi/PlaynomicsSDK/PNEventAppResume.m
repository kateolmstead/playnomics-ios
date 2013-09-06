//
//  PNEventAppResume.m
//  iosapi
//
//  Created by Jared Jenkins on 8/28/13.
//
//

#import "PNEventAppResume.h"

@implementation PNEventAppResume

- (id) initWithSessionInfo:(PNGameSessionInfo *)sessionInfo instanceId:(PNGeneratedHexId *)instanceId sessionPauseTime : (NSTimeInterval) sessionPauseTime sessionStartTime: (NSTimeInterval) sessionStartTime sequenceNumber: (int) sequenceNumber {
    if((self = [super initWithSessionInfo:sessionInfo instanceId: instanceId])){
       
        signed long long sessionStartTimeInMilliseconds = sessionStartTime * 1000;
        signed long long sessionPauseTimeInMilliseconds = sessionPauseTime * 1000;
        
        [self appendParameter: [NSNumber numberWithLongLong: sessionPauseTimeInMilliseconds] forKey: PNEventParameterSessionPauseTime];
        [self appendParameter: [NSNumber numberWithLongLong: sessionStartTimeInMilliseconds] forKey: PNEventParameterSessionStartTime];
        [self appendParameter: [NSNumber numberWithInt: sequenceNumber] forKey: PNEventParameterSequence];
    }
    return self;
}

- (NSString *) baseUrlPath{
    return @"appResume";
}

@end
