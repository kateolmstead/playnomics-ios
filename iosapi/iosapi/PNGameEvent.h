#import "PNEvent.h"

@interface PNGameEvent : PNEvent {
  signed long long _sessionId;
  signed long long _instanceId;
  NSString * _site;
  NSString * _type;
  NSString * _gameId;
  NSString * _reason;
}

@property(nonatomic, assign) signed long long sessionId;
@property(nonatomic, assign) signed long long instanceId;
@property(nonatomic, retain) NSString * type;
@property(nonatomic, retain) NSString * gameId;
@property(nonatomic, retain) NSString * reason;
@property(nonatomic, retain) NSString * site;

- (id) init:  (PNEventType)eventType
          applicationId:(signed long long) applicationId
                 userId:(NSString *)userId
              sessionId:(signed long long)sessionId
             instanceId:(signed long long)instanceId
                   site:(NSString *)site
                   type:(NSString *)type
                 gameId:(NSString *)gameId
                 reason:(NSString *)reason;
@end
