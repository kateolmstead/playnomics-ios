//
//  PNEventAppPause.m
//  iosapi
//
//  Created by Jared Jenkins on 8/28/13.
//
//

#import "PNEventAppPause.h"

@implementation PNEventAppPause

- (id) initWithSessionInfo:(PNGameSessionInfo *)sessionInfo instanceId:(PNGeneratedHexId *)instanceId sessionStartTime:(NSTimeInterval) sessionStartTime sequenceNumber : (int) sequenceNumber touches:(int) touches totalTouches:(int) totalTouches  {
    
    if((self = [super initWithSessionInfo: sessionInfo instanceId: instanceId])){
        const int keysPressed = 0;
        const int totalKeysPressed = 0;
        const int collectionMode = 8;
        
        signed long long sessionStartTimeInMilliseconds = sessionStartTime * 1000;
        signed long long updateTimeInterval = PNUpdateTimeInterval* 1000;
        
        [self appendParameter:[NSNumber numberWithInt: sequenceNumber] forKey: PNEventParameterSequence];
        [self appendParameter:[NSNumber numberWithInt: touches] forKey: PNEventParameterTouches];
        [self appendParameter:[NSNumber numberWithInt: totalTouches] forKey: PNEventParameterTotalTouches];
        [self appendParameter:[NSNumber numberWithInt: keysPressed] forKey: PNEventParameterKeysPressed];
        [self appendParameter:[NSNumber numberWithInt: totalKeysPressed] forKey: PNEventParameterTotalKeysPressed];
        [self appendParameter:[NSNumber numberWithInt: sequenceNumber] forKey: PNEventParameterSequence];
        [self appendParameter:[NSNumber numberWithLongLong: sessionStartTimeInMilliseconds] forKey: PNEventParameterSessionStartTime];
        [self appendParameter:[NSNumber numberWithLongLong: updateTimeInterval] forKey: PNEventParameterIntervalMilliseconds];
        [self appendParameter:[NSNumber numberWithInt: collectionMode] forKey: PNEventParameterCaptureMode];
    }
    return self;
}

- (NSString *) baseUrlPath{
    return @"appPause";
}

@end
