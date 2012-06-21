#import "PlaynomicsConstants.h"

#import "PlaynomicsEvent.h"

@interface BasicEvent : PlaynomicsEvent {
  NSString * _cookieId;
  NSString * _sessionId;
  NSString * _instanceId;
  NSDate * _sessionStartTime;
  NSDate * _pauseTime;
  int _sequence;
  int _timeZoneOffset;
  int _clicks;
  int _totalClicks;
  int _keys;
  int _totalKeys;
  int _collectMode;
}

@property (nonatomic, retain) NSString * cookieId;
@property (nonatomic, retain) NSString * sessionId;
@property (nonatomic, retain) NSString * instanceId;
@property (nonatomic, retain) NSDate * sessionStartTime;
@property (nonatomic, retain) NSDate * pauseTime;
@property (nonatomic, assign) int sequence;
@property (nonatomic, assign) int timeZoneOffset;
@property (nonatomic, assign) int clicks;
@property (nonatomic, assign) int totalClicks;
@property (nonatomic, assign) int keys;
@property (nonatomic, assign) int totalKeys;
@property (nonatomic, assign) int collectMode;

- (id) init: (EventType) eventType
        applicationId: (NSNumber *) applicationId
     userId:(NSString *)userId
   cookieId:(NSString *)cookieId
  sessionId:(NSString *)sessionId
 instanceId:(NSString *)instanceId
sessionStartTime:(NSDate *)sessionStartTime 
   sequence:(int)sequence
     clicks:(int)clicks
totalClicks:(int)totalClicks
       keys:(int)keys
  totalKeys:(int)totalKeys
collectMode:(int)collectMode;

- (id) init: (EventType) eventType 
applicationId:(NSNumber *)applicationId
     userId:(NSString *)userId
   cookieId:(NSString *)cookieId
  sessionId:(NSString *)sessionId
 instanceId:(NSString *)instanceId
timeZoneOffset:(int)timeZoneOffset;
@end
