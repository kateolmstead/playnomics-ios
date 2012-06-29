#import "PNEvent.h"

@interface PNSocialEvent : PNEvent {
  NSString * _invitationId;
  NSString * _recipientUserId;
  NSString * _recipientAddress;
  NSString * _method;
  PNResponseType _response;
}

@property(nonatomic, retain) NSString * invitationId;
@property(nonatomic, retain) NSString * recipientUserId;
@property(nonatomic, retain) NSString * recipientAddress;
@property(nonatomic, retain) NSString * method;
@property(nonatomic, assign) PNResponseType response;

- (id) init:  (PNEventType) eventType 
         applicationId: (long) applicationId 
                userId: (NSString *) userId 
          invitationId: (NSString *) invitationId 
       recipientUserId: (NSString *) recipientUserId 
      recipientAddress: (NSString *) recipientAddress 
                method: (NSString *) method 
              response: (PNResponseType) response;
@end
