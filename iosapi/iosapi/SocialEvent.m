#import "SocialEvent.h"

long const serialVersionUID = 1L;

@implementation SocialEvent

@synthesize invitationId=_invitationId;
@synthesize recipientUserId=_recipientUserId;
@synthesize recipientAddress=_recipientAddress;
@synthesize method=_method;
@synthesize response=_response;

- (id) init:  (PLEventType) eventType 
         applicationId: (long) applicationId 
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

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:_invitationId forKey:@"PLSocialEvent._invitationId"];
    [encoder encodeObject:_recipientUserId forKey:@"PLSocialEvent._recipientUserId"];
    [encoder encodeObject:_recipientAddress forKey:@"PLSocialEvent._recipientAddress"];
    [encoder encodeObject:_method forKey:@"PLSocialEvent._method"];
    [encoder encodeInt:_response forKey:@"PLSocialEvent._response"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _invitationId = (NSString *) [[decoder decodeObjectForKey:@"PLSocialEvent._invitationId"] retain];
        _recipientUserId= (NSString *) [[decoder decodeObjectForKey:@"PLSocialEvent._recipientUserId"] retain];
        _recipientAddress = (NSString *) [[decoder decodeObjectForKey:@"PLSocialEvent._recipientAddress"] retain];
        _method = (NSString *) [[decoder decodeObjectForKey:@"PLSocialEvent._method"] retain];
        _response = [decoder decodeIntForKey:@"PLSocialEvent._response"];
    }
    return self;
}
@end
