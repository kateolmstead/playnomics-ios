
#import "PNExplicitEvent.h"

@interface PNEventUserInfo : PNExplicitEvent
- (id) initWithSessionInfo:(PNGameSessionInfo *)info
                 pushToken:(NSString *) pushToken;

- (id) initWithSessionInfo:(PNGameSessionInfo *)info
          limitAdvertising:(BOOL) limitAdvertising
                      idfa:(NSString *) idfa
                      idfv:(NSString *) idfv;

-(id) initWithSessionInfo:(PNGameSessionInfo *)info
                   source:(NSString *) source
                 campaign:(NSString *) campaign
              installDate:(NSDate *) installDate;

- (NSString *) baseUrlPath;
@end
