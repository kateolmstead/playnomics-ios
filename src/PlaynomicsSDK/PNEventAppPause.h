//
//  PNEventAppPause.h
//  iosapi
//
//  Created by Jared Jenkins on 8/28/13.
//
//

#import "PNImplicitEvent.h"

@interface PNEventAppPause : PNImplicitEvent

- (id) initWithSessionInfo:(PNGameSessionInfo *)sessionInfo instanceId:(PNGeneratedHexId *)instanceId sessionStartTime:(NSTimeInterval) sessionStartTime sequenceNumber : (int) sequenceNumber touches:(int) touches totalTouches:(int) totalTouches;
- (NSString *) baseUrlPath;
@end
