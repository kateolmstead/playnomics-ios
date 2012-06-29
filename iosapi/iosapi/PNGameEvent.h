#import "PNEvent.h"

@interface PNGameEvent : PNEvent {
  NSString * _sessionId;
  NSString * _site;
  NSString * _instanceId;
  NSString * _type;
  NSString * _gameId;
  NSString * _reason;
}

@property(nonatomic, retain) NSString * sessionId;
@property(nonatomic, retain) NSString * instanceId;
@property(nonatomic, retain) NSString * type;
@property(nonatomic, retain) NSString * gameId;
@property(nonatomic, retain) NSString * reason;
@property(nonatomic, retain) NSString * site;

- (id) init:  (PNEventType)eventType 
            applicationId: (long) applicationId 
                 userId:(NSString *)userId
              sessionId:(NSString *)sessionId
                   site:(NSString *)site
             instanceId:(NSString *)instanceId
                   type:(NSString *)type
                 gameId:(NSString *)gameId
                 reason:(NSString *)reason;
@end
