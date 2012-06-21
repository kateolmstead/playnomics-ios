#import <Foundation/Foundation.h>

// TODO revisit naming
typedef enum {
    ET_appStart,
    ET_appPage,
    ET_appRunning,
    ET_appPause,
    ET_appResume,
    ET_appStop,
    ET_userInfo,
    ET_sessionStart,
    ET_sessionEnd,
    ET_gameStart,
    ET_gameEnd,
    ET_transaction,
    ET_invitationSent,
    ET_invitationResponse
} EventType;

EventType EventTypeValueOf(NSString *text);
NSString* EventTypeDescription(EventType value);

@interface PlaynomicsEvent : NSObject {
    EventType _eventType;
    NSDate * _eventTime;
    NSNumber * _applicationId;
    NSString * _userId;
}

@property (nonatomic, assign) EventType eventType;
@property (nonatomic, retain) NSDate *eventTime;
@property (nonatomic, retain) NSNumber *applicationId;
@property (nonatomic, retain) NSString *userId;

- (id) init:(EventType)eventType applicationId:(NSNumber *)applicationId userId:(NSString *)userId;
- (NSString *) description;
- (NSString *) addOptionalParam:(NSString *)url name:(NSString *)name value:(NSObject *)value;
- (NSString *) toQueryString;
@end
