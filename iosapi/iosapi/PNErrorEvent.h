//
//  PNErrorEvent.h
//  iosapi
//
//  Created by Eric McConkie on 1/22/13.
//
//

#import "PNErrorDetail.h"
#import "PNEvent.h"


@interface PNErrorEvent : PNEvent

@property (nonatomic,retain)PNErrorDetail *errorDetailObject;
- (id)init:(PNEventType)eventType applicationId:(long long)applicationId userId:(NSString *)userId cookieId:(NSString *)cookieId errorDetails:(PNErrorDetail*)errorDetails;
@end
