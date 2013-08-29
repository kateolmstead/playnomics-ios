
#import "PNExplicitEvent.h"

@interface PNUserInfoEvent : PNExplicitEvent
- (id) initWithSessionInfo:(PNGameSessionInfo *)info pushToken : (NSString *) pushToken;
- (id) initWithSessionInfo:(PNGameSessionInfo *)info limitAdvertising: (BOOL) limitAdvertising idfa: (NSUUID *) idfa idfv: (NSUUID *) idfv;
- (NSString *) baseUrlPath;
@end
