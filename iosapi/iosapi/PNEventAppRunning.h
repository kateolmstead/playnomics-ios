//
//  PNEventAppRunning.h
//  iosapi
//
//  Created by Jared Jenkins on 8/28/13.
//
//

#import "PNImplicitEvent.h"

@interface PNEventAppRunning : PNImplicitEvent
- (id) initWithSessionInfo:(PNGameSessionInfo *)sessionInfo instanceId:(PNGeneratedHexId *)instanceId sessionStartTime : (NSTimeInterval) sessionStartTime sequenceNumber : (int) sequenceNumber touches:(int) clicks totalTouches:(int) totalTouches;
- (NSString *) baseUrlPath;
@end
