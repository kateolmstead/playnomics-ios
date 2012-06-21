#import "PlaynomicsEvent.h"

typedef enum {
    accepted
} ResponseType;

@interface SocialEvent : PlaynomicsEvent {
  NSString * invitationId;
  NSString * recipientUserId;
  NSString * recipientAddress;
  NSString * method;
  ResponseType * response;
}

@property(nonatomic, retain) NSString * invitationId;
@property(nonatomic, retain) NSString * recipientUserId;
@property(nonatomic, retain) NSString * recipientAddress;
@property(nonatomic, retain) NSString * method;
@property(nonatomic) ResponseType * response;

- (id) init:(EventType *)eventType applicationId:(NSNumber *)applicationId userId:(NSString *)userId invitationId:(NSString *)invitationId recipientUserId:(NSString *)recipientUserId recipientAddress:(NSString *)recipientAddress method:(NSString *)method response:(ResponseType *)response;
- (void) setInvitationId:(NSString *)invitationId;
- (void) setRecipientUserId:(NSString *)recipientUserId;
- (void) setRecipientAddress:(NSString *)recipientAddress;
- (void) setMethod:(NSString *)method;
- (void) setResponse:(ResponseType *)response;
- (NSString *) toQueryString;
@end
