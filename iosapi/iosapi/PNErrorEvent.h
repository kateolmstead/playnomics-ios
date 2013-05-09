//
//  PNErrorEvent.h
//  iosapi
//
//  Created by Eric McConkie on 1/22/13.
//
//

#import "PNEvent.h"

typedef enum
{
    PNErrorTypeUndefined,
    PNErrorTypeInvalidJson
}PNErrorType;



@interface PNErrorDetail : NSObject
@property (nonatomic) PNErrorType errorType;
+(PNErrorDetail*)pNErrorDetailWithType:(PNErrorType)errorType;
@end


@interface PNErrorEvent : PNEvent

- (id)init:(PNEventType)eventType
applicationId:(long long)applicationId
    userId:(NSString *)userId
  cookieId:(NSString *)cookieId
errorDetails:(PNErrorDetail*)errorDetails;
@property (nonatomic,retain)PNErrorDetail *errorDetailObject;
@end
