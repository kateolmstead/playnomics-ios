#import <Foundation/Foundation.h>


typedef enum {
  appStart,
  appPage,
  appRunning,
  appPause,
  appResume,
  appStop,
  userInfo,
  sessionStart,
  sessionEnd,
  gameStart,
  gameEnd,
  transaction,
  invitationSent,
  invitationResponse
} EventType;

EventType EventTypeValueOf(NSString *text);
NSString* EventTypeDescription(EventType value);

@interface PlaynomicsEvent : NSObject {
  EventType eventType;
  NSDate * eventTime;
  NSNumber * applicationId;
  NSString * userId;
}

- (id) init:(EventType)eventType applicationId:(NSNumber *)applicationId userId:(NSString *)userId;
- (id) init;
- (EventType) getEventType;
- (void) setEventType:(EventType)eventType;
- (NSDate *) getEventTime;
- (void) setEventTime:(NSDate *)eventTime;
- (NSNumber *) getApplicationId;
- (void) setApplicationId:(NSNumber *)applicationId;
- (NSString *) getUserId;
- (void) setUserId:(NSString *)userId;
- (NSString *) description;
- (NSString *) addOptionalParam:(NSString *)url param:(NSString *)param value:(NSObject *)value;
- (NSString *) toQueryString;
@end
