#import "SocialEvent.h"

long const serialVersionUID = 1L;

@implementation SocialEvent

@synthesize invitationId;
@synthesize recipientUserId;
@synthesize recipientAddress;
@synthesize method;
@synthesize response;

- (id) init:(EventType *)eventType applicationId:(NSNumber *)applicationId userId:(NSString *)userId invitationId:(NSString *)invitationId recipientUserId:(NSString *)recipientUserId recipientAddress:(NSString *)recipientAddress method:(NSString *)method response:(ResponseType *)response {
  if (self = [super init:eventType param1:applicationId param2:userId]) {
    self.invitationId = invitationId;
    self.recipientUserId = recipientUserId;
    self.recipientAddress = recipientAddress;
    self.method = method;
    self.response = response;
  }
  return self;
}

- (NSString *) toQueryString {
  NSString * queryString = [[[[[self eventType] stringByAppendingString:@"?t="] + [[self eventTime] time] stringByAppendingString:@"&a="] + [self applicationId] stringByAppendingString:@"&u="] + [self userId] stringByAppendingString:@"&ii="] + [self invitationId];
  if ([self eventType] == EventType.invitationResponse) {
    queryString = [queryString stringByAppendingString:[[@"&ie=" stringByAppendingString:[self response]] stringByAppendingString:@"&ir="] + [self recipientUserId]];
  }
   else {
    queryString = [self addOptionalParam:queryString param1:@"ir" param2:[self recipientUserId]];
    queryString = [self addOptionalParam:queryString param1:@"ia" param2:[self recipientAddress]];
    queryString = [self addOptionalParam:queryString param1:@"im" param2:[self method]];
  }
  return queryString;
}

- (void) dealloc {
  [invitationId release];
  [recipientUserId release];
  [recipientAddress release];
  [method release];
  [response release];
  [super dealloc];
}

@end
