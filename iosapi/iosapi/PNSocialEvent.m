#import "PNSocialEvent.h"

@implementation PNSocialEvent

@synthesize invitationId=_invitationId;
@synthesize recipientUserId=_recipientUserId;
@synthesize recipientAddress=_recipientAddress;
@synthesize method=_method;
@synthesize response=_response;

- (id) init:  (PNEventType) eventType 
         applicationId: (signed long long) applicationId
                userId: (NSString *) userId 
              cookieId: (NSString *) cookieId
          invitationId: (signed long long) invitationId
       recipientUserId: (NSString *) recipientUserId 
      recipientAddress: (NSString *) recipientAddress 
                method: (NSString *) method 
              response: (PNResponseType) response {
    
    if ((self = [super init:eventType applicationId:applicationId userId:userId cookieId:cookieId])) {
        _invitationId = invitationId;
        _recipientUserId = [recipientUserId retain];
        _recipientAddress = [recipientAddress retain];
        _method = [method retain];
        _response = response;
    }
    return self;
}

- (NSString *) toQueryString {
    NSString * queryString = [[super toQueryString] stringByAppendingFormat:@"&ii=%lld", [self invitationId]];
    
    if ([self eventType] == PNEventInvitationResponse) {
        queryString = [queryString stringByAppendingFormat:@"&ie=%@&ir=%@&jsh=%@", [PNUtil PNResponseTypeDescription:[self response]], [self recipientUserId], [self internalSessionId]];
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
    
    [encoder encodeInt64:_invitationId forKey:@"PNSocialEvent._invitationId"];
    [encoder encodeObject:_recipientUserId forKey:@"PNSocialEvent._recipientUserId"];
    [encoder encodeObject:_recipientAddress forKey:@"PNSocialEvent._recipientAddress"];
    [encoder encodeObject:_method forKey:@"PNSocialEvent._method"];
    [encoder encodeInt:_response forKey:@"PNSocialEvent._response"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _invitationId = [decoder decodeInt64ForKey:@"PNSocialEvent._invitationId"];
        _recipientUserId= (NSString *) [[decoder decodeObjectForKey:@"PNSocialEvent._recipientUserId"] retain];
        _recipientAddress = (NSString *) [[decoder decodeObjectForKey:@"PNSocialEvent._recipientAddress"] retain];
        _method = (NSString *) [[decoder decodeObjectForKey:@"PNSocialEvent._method"] retain];
        _response = [decoder decodeIntForKey:@"PNSocialEvent._response"];
    }
    return self;
}
@end
