//
//  PNErrorEvent.m
//  iosapi
//
//  Created by Eric McConkie on 1/22/13.
//
//

#import "PNErrorEvent.h"

@implementation PNErrorDetail
@synthesize errorType = _errorType;

+(PNErrorDetail*)pNErrorDetailWithType:(PNErrorType)errorType
{
    PNErrorDetail *details = [[[PNErrorDetail alloc] init] autorelease];
    [details setErrorType:errorType];
    return details;
}
@end

@implementation PNErrorEvent
@synthesize errorDetailObject = _errorDetailObject;

- (id)init:(PNEventType)eventType
applicationId:(long long)applicationId
    userId:(NSString *)userId
  cookieId:(NSString *)cookieId
errorDetaios:(PNErrorDetail*)errorDetails
{
    self = [super init:eventType applicationId:applicationId userId:userId cookieId:cookieId];
    
    if (self) {
        [self setErrorDetailObject:errorDetails];
        
    }
    return self;
}


- (NSString *) toQueryString {
    
    //define the message here for sending back the error
    NSString *errorMessage = nil;
    switch (self.errorDetailObject.errorType) {
        case PNErrorTypeInvalidJson:
            errorMessage = @"invalid_json";
            break;
            
        default:
            errorMessage = @"unknown";
            break;
    }
    
    NSString * queryString = nil;
    queryString = [[super toQueryString] stringByAppendingFormat:@"&m=%@",
                   errorMessage
                   ];
    return queryString;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        
        
    }
    return self;
}
@end
