#import "PlaynomicsEvent.h"

typedef enum {
    accepted
} ResponseType;

@interface SocialEvent : PlaynomicsEvent {
  NSString * _invitationId;
  NSString * _recipientUserId;
  NSString * _recipientAddress;
  NSString * _method;
  ResponseType _response;
}

@property(nonatomic, retain) NSString * invitationId;
@property(nonatomic, retain) NSString * recipientUserId;
@property(nonatomic, retain) NSString * recipientAddress;
@property(nonatomic, retain) NSString * method;
@property(nonatomic, assign) ResponseType response;

- (id) init: (EventType) eventType 
         applicationId: (NSNumber *) applicationId 
                userId: (NSString *) userId 
          invitationId: (NSString *) invitationId 
       recipientUserId: (NSString *) recipientUserId 
      recipientAddress: (NSString *) recipientAddress 
                method: (NSString *) method 
              response: (ResponseType) response;
@end
