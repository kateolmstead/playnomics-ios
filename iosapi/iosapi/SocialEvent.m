#import "SocialEvent.h"

long const serialVersionUID = 1L;

@implementation SocialEvent

@synthesize invitationId=_invitationId;
@synthesize recipientUserId=_recipientUserId;
@synthesize recipientAddress=_recipientAddress;
@synthesize method=_method;
@synthesize response=_response;

- (id) init:  (PLEventType) eventType 
         applicationId: (NSNumber *) applicationId 
                userId: (NSString *) userId 
          invitationId: (NSString *) invitationId 
       recipientUserId: (NSString *) recipientUserId 
      recipientAddress: (NSString *) recipientAddress 
                method: (NSString *) method 
              response: (PLResponseType) response {
    
    if ((self = [super init:eventType applicationId:applicationId userId:userId])) {
        _invitationId = invitationId;
        _recipientUserId = recipientUserId;
        _recipientAddress = recipientAddress;
        _method = method;
        _response = response;
    }
    return self;
}

- (NSString *) toQueryString {
    NSString * queryString = [[super toQueryString] stringByAppendingFormat:@"&ii=%@", [self invitationId]];
    
    if ([self eventType] == PLEventInvitationResponse) {
        queryString = [queryString stringByAppendingFormat:@"&ie=%@&ir=%@", [self response], [self recipientUserId]];
    }
    else {
        queryString = [self addOptionalParam:queryString name:@"ir" value:[self recipientUserId]];
        queryString = [self addOptionalParam:queryString name:@"ia" value:[self recipientAddress]];
        queryString = [self addOptionalParam:queryString name:@"im" value:[self method]];
    }
    return queryString;
}

@end
