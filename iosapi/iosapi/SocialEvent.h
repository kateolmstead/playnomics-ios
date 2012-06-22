#import "PlaynomicsEvent.h"

@interface SocialEvent : PlaynomicsEvent {
  NSString * _invitationId;
  NSString * _recipientUserId;
  NSString * _recipientAddress;
  NSString * _method;
  PLResponseType _response;
}

@property(nonatomic, retain) NSString * invitationId;
@property(nonatomic, retain) NSString * recipientUserId;
@property(nonatomic, retain) NSString * recipientAddress;
@property(nonatomic, retain) NSString * method;
@property(nonatomic, assign) PLResponseType response;

- (id) init:  (PLEventType) eventType 
         applicationId: (long) applicationId 
                userId: (NSString *) userId 
          invitationId: (NSString *) invitationId 
       recipientUserId: (NSString *) recipientUserId 
      recipientAddress: (NSString *) recipientAddress 
                method: (NSString *) method 
              response: (PLResponseType) response;
@end
