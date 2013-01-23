//
//  PNErrorEvent.h
//  iosapi
//
//  Created by Eric McConkie on 1/22/13.
//
//

#import "PNEvent.h"
#import "PNErrorDetail.h"

@interface PNErrorEvent : PNEvent

- (id)init:(PNEventType)eventType
applicationId:(long long)applicationId
    userId:(NSString *)userId
  cookieId:(NSString *)cookieId
errorDetaios:(PNErrorDetail*)errorDetails;
@property (nonatomic,retain)PNErrorDetail *errorDetailObject;
@end
