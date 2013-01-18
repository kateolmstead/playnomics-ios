#import "PNEvent.h"

@interface PNSocialEvent : PNEvent {
  signed long long _invitationId;
  NSString * _recipientUserId;
  NSString * _recipientAddress;
  NSString * _method;
  PNResponseType _response;
}

@property(nonatomic, assign) signed long long invitationId;
@property(nonatomic, retain) NSString * recipientUserId;
@property(nonatomic, retain) NSString * recipientAddress;
@property(nonatomic, retain) NSString * method;
@property(nonatomic, assign) PNResponseType response;

- (id) init:  (PNEventType) eventType 
         applicationId: (signed long long) applicationId
                userId: (NSString *) userId
              cookieId: (NSString *) cookieId
          invitationId: (signed long long) invitationId
       recipientUserId: (NSString *) recipientUserId 
      recipientAddress: (NSString *) recipientAddress 
                method: (NSString *) method 
              response: (PNResponseType) response;
@end
