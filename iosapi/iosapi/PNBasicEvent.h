#import "PNEvent.h"

@interface PNBasicEvent : PNEvent {
  NSString * _cookieId;
  NSString * _sessionId;
  NSString * _instanceId;
  NSTimeInterval _sessionStartTime;
  NSTimeInterval _pauseTime;
  int _sequence;
  int _timeZoneOffset;
  int _clicks;
  int _totalClicks;
  int _keys;
  int _totalKeys;
  int _collectMode;
}

@property (nonatomic, retain) NSString * cookieId;
@property (nonatomic, retain) NSString * instanceId;
@property (nonatomic, assign) NSTimeInterval sessionStartTime;
@property (nonatomic, assign) NSTimeInterval pauseTime;
@property (nonatomic, assign) int sequence;
@property (nonatomic, assign) int timeZoneOffset;
@property (nonatomic, assign) int clicks;
@property (nonatomic, assign) int totalClicks;
@property (nonatomic, assign) int keys;
@property (nonatomic, assign) int totalKeys;
@property (nonatomic, assign) int collectMode;

- (id) init:  (PNEventType) eventType
        applicationId:(long) applicationId
     userId:(NSString *)userId
   cookieId:(NSString *)cookieId
  sessionId:(NSString *)sessionId
 instanceId:(NSString *)instanceId
sessionStartTime:(NSTimeInterval)sessionStartTime 
   sequence:(int)sequence
     clicks:(int)clicks
totalClicks:(int)totalClicks
       keys:(int)keys
  totalKeys:(int)totalKeys
collectMode:(int)collectMode;

- (id) init:  (PNEventType) eventType 
applicationId:(long) applicationId
     userId:(NSString *)userId
   cookieId:(NSString *)cookieId
  sessionId:(NSString *)sessionId
 instanceId:(NSString *)instanceId
timeZoneOffset:(int)timeZoneOffset;

- (void) setup;
@end
