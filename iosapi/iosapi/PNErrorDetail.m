//
//  PNErrorDetails.m
//  iosapi
//
//  Created by Eric McConkie on 1/22/13.
//
//

#import "PNErrorDetail.h"


@implementation PNErrorDetail
@synthesize errorType = _errorType;

+(PNErrorDetail*)pNErrorDetailWithType:(PNErrorType)errorType
{
    PNErrorDetail *details = [[[PNErrorDetail alloc] init] autorelease];
    [details setErrorType:errorType];
    return details;
}
@end