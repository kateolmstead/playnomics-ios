//
//  PNEventAppResume.h
//  iosapi
//
//  Created by Jared Jenkins on 8/28/13.
//
//

#import "PNImplicitEvent.h"

@interface PNEventAppResume : PNImplicitEvent

- (id) initWithSessionInfo:(PNGameSessionInfo *)sessionInfo instanceId:(PNGeneratedHexId *)instanceId sessionPauseTime : (NSTimeInterval) sessionPauseTime sessionStartTime: (NSTimeInterval) sessionStartTime sequenceNumber: (int) sequenceNumber;

- (NSString *) baseUrlPath;

@end
