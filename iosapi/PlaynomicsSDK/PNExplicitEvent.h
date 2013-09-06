//
//  PNExplicitEvent.h
//  iosapi
//
//  Created by Jared Jenkins on 8/28/13.
//
//

#import "PNEvent.h"

@interface PNExplicitEvent : PNEvent
- (id) initWithSessionInfo:(PNGameSessionInfo *)info;
- (NSString *) sessionKey;
@end
