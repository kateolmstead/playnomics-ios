//
//  PNErrorDetails.h
//  iosapi
//
//  Created by Eric McConkie on 1/22/13.
//
//

#import <Foundation/Foundation.h>

@interface PNErrorDetail : NSObject
@property (nonatomic) PNErrorType errorType;
+(PNErrorDetail*)pNErrorDetailWithType:(PNErrorType)errorType;
@end
